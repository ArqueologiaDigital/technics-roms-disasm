#!/usr/bin/env python3
r"""harmonize_by_caller_alignment.py -- give v7 (or v9) the v10 name of the same routine where
the address-delta method cannot see it, by lining up the CALLERS.

QUESTION ANSWERED / JOB IT DOES
    scripts/renaming/harmonize_version_labels.py pairs a v10 label with a target (v7/v9) address
    only between two shared anchors whose v10->target deltas are equal.  Where v7's code moved
    non-uniformly (most of the regions v7 differs in), it finds nothing, and the header
    propagation review (analysis/header-propagation/review-2026-10-24.tsv) is left with
    `names-absent-symbol` rows: v10's header names a callee that v7 holds under a placeholder
    (`DMA_ChannelHandler_3_Helper` for v10's `DisplayStr_ShowMeasureNumber`) or without a label.

    This tool finds the correspondence through the code that USES the routine:
      1. ALIGN.  Both linked ELFs are disassembled (llvm-objdump, cached in --cache).  From every
         label defined under the same name in both images, the two instruction streams are
         walked in parallel up to the next shared label, and stop at the first pair whose text
         differs once every number is masked, or whose lengths differ.
      2. PAIR.  In every aligned instruction pair, a 24-bit ROM operand (call/jp/ld target, or
         the target of a relative jr/jrl/calr/djnz) gives a pair (v10 address, target address).
         A v10 address paired with two different target addresses is dropped as ambiguous.
      3. CANDIDATE.  A paired v10 address that carries a v10 label the target does not define is
         a candidate: RENAME when the target has a label there (column-0 label in the ELF, or an
         assembler-local `.Lc_<addr>`), INSERT when it has none.
      4. PROOF (body equivalence).  The v10 routine is compared with the target bytes over its
         extent (from the label to the next v10 label that does not extend its name, as in
         propagate_v10_headers.py's Tree.span, and at least the first instruction), instruction
         by instruction: equal masked text and length; every number that differs must be
           * a RAM operand moved by the measured v10->v7 map
             (analysis/header-propagation/v7-ram-shift-2026-10-24.txt; v9's RAM equals v10's),
           * or a ROM address / relative-branch target.  Such a pointer is CHECKED where it can
             be: internal (same offset into both bodies), or a v10 label the target defines
             (the target address must be that label's) -- a contradiction fails the proof --
             or a pair from step 2 (must agree).  Pointers none of these can check are counted
             as `unchecked`, which is reported.
         The candidate is accepted only when nothing is unexplained or contradicted.
    Accepted renames go to a generated sed script (project rule), applied to the target's .s,
    .ld and (code segments of) .c files; inserts put `Name:` in front of the source line that
    emits the address (the marker mirror of symbolize_numeric_branches.build_map, refused unless
    it reproduces the dump).  A v7 name that is not a placeholder (STRUCT pattern, `.Lc_`, or a
    `_Wrapper`/`_Tbl` suffix) is NOT replaced unless --rename-named; those rows are reported as
    `both-named` for a reader to decide.  Labels emit no bytes: `make gate` proves it.

RUN
    make all
    python3 scripts/renaming/harmonize_by_caller_alignment.py --to v7 --cache DIR --report OUT.tsv
    python3 scripts/renaming/harmonize_by_caller_alignment.py --to v7 --cache DIR --report OUT.tsv --apply
    (re-run after `make all`: every new shared name is a new anchor.  --cache must be a scratch
    directory; the disassembly is redone when an ELF is newer than its cache.)
"""
import argparse
import bisect
import collections
import datetime
import glob
import os
import re
import subprocess
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BIN = os.path.expanduser("~/compartilhado/llvm-project/build/bin")
sys.path.insert(0, os.path.join(REPO, "scripts", "converters"))
sys.path.insert(0, os.path.join(REPO, "scripts", "analysis"))
STRUCT = re.compile(r'_(Skip|Join|Loop|Return|Helper|Epilogue|Entry|Tail|Next|Done|Exit|End|'
                    r'Code|Data|Block|Sub|Case|Default)\d*$|_0x[0-9A-Fa-f]+$|^LABEL_|^sub_|^loc_')
PLACEHOLDER = re.compile(STRUCT.pattern + r'|^\.Lc_|_Wrapper\d*$|_Tbl\d*$|_Helper\d*_|_Data_\d+$')
NUM = re.compile(r'(?<![\w.])-?(?:0x[0-9a-fA-F]+|\d+)\b')
REL = {"jr", "jrl", "calr", "djnz"}
MAP = os.path.join(REPO, "analysis", "header-propagation", "v7-ram-shift-2026-10-24.txt")
ROMLO, ROMHI = 0xE00000, 0xFFFFFF


def load_runs(target):
    if target != "v7":
        return []
    runs = []
    for line in open(MAP):
        m = re.match(r'^0x([0-9a-f]+)\s+0x([0-9a-f]+)\s+([+-]\d+)', line)
        if m:
            runs.append((int(m.group(1), 16), int(m.group(2), 16), int(m.group(3))))
    return runs


def ram_delta(runs, v):
    for lo, hi, d in runs:
        if lo <= v <= hi:
            return d
    return None


def elf(v):
    return os.path.join(REPO, "rebuilt_ROMs", "kn5000_%s_program.llvm.elf" % v)


def disasm(v, cache):
    """-> (sorted addrs, {addr: (mnemonic, operand_text, length)})."""
    out = os.path.join(cache, "%s.dis" % v)
    if not os.path.exists(out) or os.path.getmtime(out) < os.path.getmtime(elf(v)):
        with open(out + ".tmp", "w") as fh:
            subprocess.run([os.path.join(BIN, "llvm-objdump"), "-d", "--no-show-raw-insn", elf(v)],
                           stdout=fh, check=True)
        os.replace(out + ".tmp", out)
    ins = {}
    rx = re.compile(r'^\s*([0-9a-f]+):\s*\t(\S+)\s*(.*)$')
    for line in open(out):
        m = rx.match(line)
        if m:
            ins[int(m.group(1), 16)] = [m.group(2), m.group(3).strip(), 0]
    addrs = sorted(ins)
    for i, a in enumerate(addrs[:-1]):
        ins[a][2] = addrs[i + 1] - a
    if addrs:
        ins[addrs[-1]][2] = 1
    return addrs, ins


def syms(v):
    out = subprocess.run([os.path.join(BIN, "llvm-nm"), "--defined-only", elf(v)],
                         capture_output=True, text=True, check=True).stdout
    by, at = {}, collections.defaultdict(list)
    for l in out.splitlines():
        a, t, n = l.split()
        if t.lower() != "t" or n.startswith(".L"):
            continue
        a = int(a, 16)
        by[n] = a
        at[a].append(n)
    return by, at


def source_labels(v):
    """column-0 labels of the tree's .s files, and its `.Lc_<addr>` locals by address."""
    col0, lc = set(), collections.defaultdict(list)
    for f in glob.glob(os.path.join(REPO, v, "maincpu", "**", "*.s"), recursive=True):
        for l in open(f, "rb").read().decode("latin-1").split("\n"):
            m = re.match(r'^([A-Za-z_.$][\w.$]*):', l)
            if m:
                col0.add(m.group(1))
                mm = re.match(r'^\.Lc_([0-9a-f]{6})$', m.group(1))
                if mm:
                    lc[int(mm.group(1), 16)].append(m.group(1))
    return col0, lc


def masked(insn):
    return insn[0], NUM.sub("#", insn[1])


def numbers(text):
    return [int(x, 0) for x in NUM.findall(text)]


def operand_pairs(a10, i10, a7, i7):
    """-> list of (kind, v10 value, target value) for the numbers that differ, or None when
    the two instructions do not align.  kind: 'rom' / 'rel' / 'num'."""
    if masked(i10) != masked(i7) or i10[2] != i7[2]:
        return None
    n10, n7 = numbers(i10[1]), numbers(i7[1])
    if len(n10) != len(n7):
        return None
    out = []
    for k, (x, y) in enumerate(zip(n10, n7)):
        if i10[0] in REL and k == len(n10) - 1:
            out.append(("rel", a10 + i10[2] + x, a7 + i7[2] + y))
        elif x != y:
            if ROMLO <= x <= ROMHI and ROMLO <= y <= ROMHI:
                out.append(("rom", x, y))
            else:
                out.append(("num", x, y))
    return out


def walk(A10, ins10, a10, A7, ins7, a7, stop10):
    """Parallel walk from a10/a7 while instructions align, up to stop10 (exclusive)."""
    i = bisect.bisect_left(A10, a10)
    j = bisect.bisect_left(A7, a7)
    if i >= len(A10) or j >= len(A7) or A10[i] != a10 or A7[j] != a7:
        return
    while i < len(A10) and j < len(A7) and A10[i] < stop10:
        p, q = A10[i], A7[j]
        if ins10[p][0] == "<unknown>" or ins7[q][0] == "<unknown>":
            return
        ops = operand_pairs(p, ins10[p], q, ins7[q])
        if ops is None:
            return
        yield p, q, ops
        i, j = i + 1, j + 1
        if i < len(A10) and j < len(A7) and (A10[i] - a10) != (A7[j] - a7):
            return


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--to", default="v7", choices=("v7", "v9"))
    ap.add_argument("--from", dest="frm", default="v10", choices=("v10",))
    ap.add_argument("--cache", required=True, help="scratch directory for the disassemblies")
    ap.add_argument("--report", required=True)
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--rename-named", action="store_true",
                    help="also replace target names that are not placeholders")
    ap.add_argument("--only", action="append", default=[], help="restrict to these v10 names")
    a = ap.parse_args()
    os.makedirs(a.cache, exist_ok=True)
    runs = load_runs(a.to)
    sF, aF = syms(a.frm)
    sT, aT = syms(a.to)
    col0T, lcT = source_labels(a.to)
    col0F, _ = source_labels(a.frm)
    A10, I10 = disasm(a.frm, a.cache)
    A7, I7 = disasm(a.to, a.cache)
    keysF = sorted(aF)
    keysT = sorted(aT)

    def stem(n):
        prev = None
        while prev != n:
            prev, n = n, STRUCT.sub("", n)
        return n

    def parent(keys, at, addr):
        i = bisect.bisect_right(keys, addr) - 1
        while i >= 0:
            ns = [n for n in at[keys[i]] if not STRUCT.search(n)]
            if ns:
                return set(ns)
            i -= 1
        return set()

    # A name defined in both images identifies the same place only when it is not structural, or
    # when it is structural (`X_Skip3`) and hangs off the same non-structural parent X in both:
    # structural names were numbered per tree, so `X_Skip3` in v7 is often v10's `X_Skip5`.
    trusted = set()
    for n in sF:
        if n in sT and ROMLO <= sF[n] <= ROMHI:
            if not STRUCT.search(n):
                trusted.add(n)
            else:
                st = stem(n)
                if st in parent(keysF, aF, sF[n]) and st in parent(keysT, aT, sT[n]):
                    trusted.add(n)


    # 1-2: align from every shared label, collect pointer pairs
    votes = collections.defaultdict(collections.Counter)
    shared = sorted((sF[n], sT[n]) for n in trusted)
    anchor10 = sorted({x for x, _ in shared})

    def next_label(addr):
        # a walk runs on through labels the target lacks, up to the next trusted anchor
        k = bisect.bisect_right(anchor10, addr)
        return anchor10[k] if k < len(anchor10) else addr + 0x1000
    for p10, p7 in set(shared):
        for _, _, ops in walk(A10, I10, p10, A7, I7, p7, next_label(p10)):
            for kind, x, y in ops:
                if kind in ("rom", "rel"):
                    votes[x][y] += 1
    pair = {}
    for x, c in votes.items():
        if len(c) == 1:
            pair[x] = next(iter(c))
    romF = open(os.path.join(REPO, "original_ROMs", "kn5000_%s_program.rom" % a.frm), "rb").read()
    romT = open(os.path.join(REPO, "original_ROMs", "kn5000_%s_program.rom" % a.to), "rb").read()

    def check_ptr(u, w, x, y, end):
        """True = checked, None = nothing to check it against, str = contradiction."""
        if x <= u < end and u - x == w - y:
            return True
        lab = [n for n in aF.get(u, []) if n in trusted]
        if lab:
            if any(sT[n] == w for n in lab):
                return True
            return "ptr %s: target has it at 0x%06x, code says 0x%06x" % (lab[0], sT[lab[0]], w)
        if u in pair:
            if pair[u] == w:
                return True
            return "ptr 0x%06x pairs with 0x%06x elsewhere, here 0x%06x" % (u, pair[u], w)
        return None

    def byte_proof(x, y, n):
        """v7_routine_equivalence.py's comparison, with the pointers checked."""
        A = romF[x - ROMLO:x - ROMLO + n]
        B = romT[y - ROMLO:y - ROMLO + n]
        if len(A) != n or len(B) != n:
            return (False, 0, 0, 0)
        i, ram, chk, unchk = 0, 0, 0, 0
        while i < n:
            if A[i] == B[i]:
                i += 1
                continue
            done = False
            for j in (i - 2, i - 1, i):
                if j >= 0 and j + 3 <= n:
                    u, w = int.from_bytes(A[j:j + 3], "little"), int.from_bytes(B[j:j + 3], "little")
                    if ROMLO <= u <= ROMHI and ROMLO <= w <= ROMHI:
                        v = check_ptr(u, w, x, y, x + n)
                        if isinstance(v, str):
                            return (False, 0, 0, 0)
                        chk, unchk = chk + (v is True), unchk + (v is None)
                        i, done = j + 3, True
                        break
            if not done:
                for j in (i - 1, i):
                    if j >= 0 and j + 2 <= n:
                        u, w = int.from_bytes(A[j:j + 2], "little"), int.from_bytes(B[j:j + 2], "little")
                        d = ram_delta(runs, u)
                        if d and u + d == w:
                            ram, i, done = ram + 1, j + 2, True
                            break
            if not done:
                return (False, 0, 0, 0)
        return (True, ram, chk, unchk)

    # 3: candidates
    def pick(names):
        return sorted(names, key=lambda n: (bool(STRUCT.search(n)), len(n), n))
    rows, renames, inserts = [], {}, {}
    taken = set(sT) | col0T
    stats = collections.Counter()
    for x, y in sorted(pair.items()):
        namesF = [n for n in aF.get(x, []) if n in col0F]
        if not namesF or (a.only and not set(namesF) & set(a.only)):
            continue
        if any(sT.get(n) == y for n in namesF):
            continue
        new, vacate = None, None
        for n in pick(namesF):
            if n not in taken:
                new = n
                break
        if new is None:
            # the v10 name is held by another target label that is not that place's counterpart (a structural
            # name numbered differently): usable if that holder is renamed away in the same run (a swap)
            for n in pick(namesF):
                if n in sT and n not in trusted and sT[n] != y and n not in renames.values():
                    new, vacate = n, n
                    break
        old_names = pick([n for n in aT.get(y, []) if n in col0T] + lcT.get(y, []))
        row = {"v10": pick(namesF)[0], "v10_addr": "0x%06x" % x, "to_addr": "0x%06x" % y,
               "to_names": " ".join(old_names), "votes": votes[x][y]}
        if new is None:
            row["result"] = "v10-name-defined-elsewhere-in-target"
            row["detail"] = " ".join("%s@0x%06x" % (n, sT[n]) for n in namesF if n in sT)
            stats[row["result"]] += 1
            rows.append(row)
            continue
        row["v10"] = new
        # a structural name goes where it hangs off the same parent in both trees (v10's own structural names
        # sometimes carry an earlier routine's stem: then the two parents must be the same name)
        if (STRUCT.search(new) and stem(new) not in parent(keysT, aT, y)
                and not parent(keysF, aF, x) & parent(keysT, aT, y)):
            row["result"] = "parent-differs"
            row["detail"] = "v7 parent: %s" % " ".join(sorted(parent(keysT, aT, y)))
            stats[row["result"]] += 1
            rows.append(row)
            continue
        # 4: proof over the v10 extent
        end = x
        k = bisect.bisect_right(keysF, x)
        while k < len(keysF):
            ns = aF[keysF[k]]
            if any(m.startswith(new + "_") for m in ns):
                k += 1
                continue
            end = keysF[k]
            break
        if end <= x:
            end = x + 1
        n_ins, covered, ram, chk, unchk, bad = 0, x, 0, 0, 0, []
        for p, q, ops in walk(A10, I10, x, A7, I7, y, end):
            n_ins += 1
            covered = p + I10[p][2]
            for kind, u, w in ops:
                if kind == "num":
                    d = ram_delta(runs, u)
                    if d is not None and d != 0 and u + d == w:
                        ram += 1
                    else:
                        bad.append("num %d/%d at +%d" % (u, w, p - x))
                    continue
                v = check_ptr(u, w, x, y, end)
                if v is True:
                    chk += 1
                elif v is None:
                    unchk += 1
                else:
                    bad.append(v)
        row.update(extent=end - x, insns=n_ins, ram=ram, checked=chk, unchecked=unchk)
        if covered < end or bad:
            # data, or code the disassembler frames differently: the same bytes modulo the RAM map and
            # checked pointers also prove it (a table of pointers, a record)
            bp = byte_proof(x, y, end - x)
            if bp[0]:
                row.update(ram=bp[1], checked=bp[2], unchecked=bp[3], proof="bytes")
                covered, bad = end, []
        if covered < end:
            row["result"] = "proof-failed"
            row["detail"] = "instructions stop aligning at +%d of %d" % (covered - x, end - x)
        elif bad:
            row["result"] = "proof-failed"
            row["detail"] = "; ".join(bad[:3])
        elif old_names:
            old = old_names[0]
            if (STRUCT.search(new) and stem(new) not in parent(keysT, aT, y) and STRUCT.search(old)
                    and stem(old) in parent(keysT, aT, y)):
                # v10's structural name carries another routine's stem while the target's is right: the fix
                # belongs in v10 (a re-parenting rename there, then this tool again), not here
                row["result"] = "v10-name-misparented"
            elif not PLACEHOLDER.search(old) and not a.rename_named:
                row["result"] = "both-named"
            elif old in renames:
                row["result"] = "old-name-already-renamed"
            elif old in sF and not STRUCT.search(old):
                row["result"] = "old-name-is-a-v10-name-elsewhere"
                row["detail"] = "v10 has %s at 0x%06x" % (old, sF[old])
            else:
                row["result"] = "rename"
                renames[old] = new
                taken.add(new)
                if vacate:
                    row["vacate"] = vacate
        elif vacate:
            row["result"] = "v10-name-defined-elsewhere-in-target"
            row["detail"] = "%s@0x%06x (no label here to swap with)" % (vacate, sT[vacate])
        else:
            row["result"] = "insert"
            inserts[y] = new
            taken.add(new)
        stats[row["result"]] += 1
        rows.append(row)
    # a swap stands only when the holder of the name is itself renamed away; drop the rest to a fixed point
    # (renames are applied in two passes through temporary names, so chains and cycles are safe)
    changed = True
    while changed:
        changed = False
        for r in rows:
            if r["result"] == "rename" and r.get("vacate") and r["vacate"] not in renames:
                old = r["to_names"].split()[0]
                renames.pop(old, None)
                r["result"] = "v10-name-defined-elsewhere-in-target"
                r["detail"] = "%s@0x%06x is not renamed away" % (r["vacate"], sT[r["vacate"]])
                stats["rename"] -= 1
                stats[r["result"]] += 1
                changed = True
    # inserts: locate the emitting source line
    ins_at = collections.defaultdict(list)
    if inserts:
        import symbolize_numeric_branches as snb
        img = snb.image_by_key(a.to)
        srcroot = os.path.join(REPO, img["mirror"])
        marks, addrs, spans, rom_ok, src, macros = snb.build_map(img, srcroot)
        if not rom_ok:
            sys.exit("marker mirror does not reproduce the dump: refusing")
        start_of = {s[0]: s for s in spans}
        for r in rows:
            if r["result"] != "insert":
                continue
            y = int(r["to_addr"], 16)
            sp = start_of.get(y)
            if not sp:
                r["result"] = "insert-mid-line"
                stats["insert"] -= 1
                stats["insert-mid-line"] += 1
                continue
            ins_at[sp[2]].append((sp[3], r["v10"]))
            r["detail"] = "%s:%d" % (sp[2], sp[3] + 1)
    cols = ["result", "v10", "v10_addr", "to_addr", "to_names", "votes", "extent", "insns", "proof", "ram",
            "checked", "unchecked", "detail"]
    with open(a.report, "w") as fh:
        fh.write("\t".join(cols) + "\n")
        for r in rows:
            fh.write("\t".join(str(r.get(c, "")) for c in cols) + "\n")
    if a.apply and renames:
        sed = os.path.join(REPO, "scripts", "renaming", "harmonize_%s_by_caller_alignment.sed" % a.to)
        tmp = {old: "HARMONIZE_TMP_%d_" % k for k, old in enumerate(sorted(renames))}
        lines = ["s/%s\\b/%s/g\n" % (("\\b" if not old.startswith(".") else "") + re.escape(old), tmp[old])
                 for old in sorted(renames, key=lambda o: -len(o))]
        lines += ["s/\\b%s\\b/%s/g\n" % (tmp[old], renames[old]) for old in sorted(renames)]
        fresh = not os.path.exists(sed)
        with open(sed, "a") as s:
            if fresh:
                s.write("# generated by scripts/renaming/harmonize_by_caller_alignment.py: %s labels renamed to\n"
                        "# the v10 name of the same routine (caller alignment + body-equivalence proof).\n" % a.to)
            s.write("# run %s\n" % datetime.date.today().isoformat())
            s.writelines(lines)
        fd, run_sed = tempfile.mkstemp(suffix=".sed")
        with os.fdopen(fd, "w") as s:
            s.writelines(lines)
        files = sorted(glob.glob(os.path.join(REPO, a.to, "maincpu", "**", "*.s"), recursive=True))
        files += glob.glob(os.path.join(REPO, a.to, "maincpu", "**", "*.ld"), recursive=True)
        subprocess.run(["sed", "-i", "-f", run_sed] + files, check=True)
        os.unlink(run_sed)
        from name_resname_strings import segments
        rx = re.compile(r'(?<![\w.])(%s)\b' % "|".join(sorted(map(re.escape, renames), key=len, reverse=True)))
        # one regex pass: simultaneous, so a swap needs no temporary name here
        for f in glob.glob(os.path.join(REPO, a.to, "maincpu", "**", "*.c"), recursive=True):
            txt = open(f, "rb").read().decode("latin-1")
            new_txt = "".join(rx.sub(lambda mm: renames[mm.group(1)], s) if k == "code" else s
                              for k, s in segments(txt))
            if new_txt != txt:
                with open(f + ".tmp", "wb") as fh:
                    fh.write(new_txt.encode("latin-1"))
                os.replace(f + ".tmp", f)
    if a.apply and ins_at:
        for rel, items in ins_at.items():
            p = os.path.join(srcroot, rel)
            L = open(p, "rb").read().decode("latin-1").split("\n")
            for li, nf in sorted(items, key=lambda t: -t[0]):
                L.insert(li, "%s:" % nf)
            open(p, "wb").write("\n".join(L).encode("latin-1"))
    print("%s <- %s: %d pairs; %s%s" % (a.to, a.frm, len(pair), dict(stats), "" if a.apply else " (dry run)"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
