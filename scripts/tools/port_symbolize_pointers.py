#!/usr/bin/env python3
r"""Spell the code pointers of a ported KN5000 main-program tree (v6, v5) by name.

QUESTION THIS ANSWERS
    The dispatch census (scripts/analysis/dispatch_table_census/) found, when v6 and v5 became images
    of it (2026-10-31), five code-pointer tables per tree whose entries are spelled as numbers
    (U-NOT 5): three runs of `; TODO(port)` `.byte` rows that the porter
    (scripts/converters/port_maincpu_version.py) wrote where no v7 line mapped, and two tables of the
    compiled C data (ui/sepaout_config.c) whose link script still gave v7's addresses, so the build
    patched v6's pointers in as raw bytes (TREE/maincpu/includes/TREE_c_divergence.json).  Which
    pointers can be spelled by the label the tree already has at the target, and does the image stay
    byte-identical when they are?

TWO EDITS
  rows    For each table label given, the `.byte` rows right after it (comment lines between are kept)
          are read as 32-bit little-endian words.  Every word must be 0 or the address of a label of
          the tree's ELF (a `t` symbol, not a `.L` or marker name; of several at one address the first
          in llvm-nm's order).  The rows become `.long Name` / `.long 0` lines, and the
          `; TODO(port): ...` line above them is dropped (they are no longer bytes nobody decoded).  A
          table with any other word is left as it is and reported.
  relink  Every `Name = 0x...;` line of the tree's C link scripts (TREE/maincpu/**/*_link.ld) whose
          Name the tree's ELF defines at another ROM address gets the ELF's address, which is what the
          porter's own relink pass does when it generates the tree.  The C bins that depend on a
          changed script are recompiled (make TREE-c-bins-raw), and their divergence json entries are
          recomputed against the bytes the image needs (the bins as the build patched them before),
          with the porter's rule (port_maincpu_version.py c_divergence): an aligned word that is a ROM
          address on both sides is a pointer relocation, any other differing byte a raw byte.  Only the
          bytes some `.incbin "includes/generated/<bin>", off, len` of the tree puts in the image count;
          the rest are don't-care and take the relinked bin's value (2026-10-31: ctlonly.c's 36 handler
          words are such bytes, the tree spells Scoop_StaticOpHandlerTable as `.long` lines, so its
          link script could not be relinked before).  The
          scripts are taken one at a time, and one whose bins would carry more patched entries
          afterwards is put back as it was and reported (REFUSED).  A script whose bins would carry
          more patched bytes afterwards is put back (none did on 2026-10-31).
  Both rebuild the tree's image and restore every file if it is not byte-identical to the reference.

RUN (repository root, a built tree: rebuilt_ROMs/kn5000_TREE_program.llvm.elf must match its ROM)
    python3 scripts/tools/port_symbolize_pointers.py rows --tree v6 InitializeMurai_PtrTable_5 \
        PerfMode_ParamHandler_4_Data SndDispatch_Handler_1_Data
    python3 scripts/tools/port_symbolize_pointers.py relink --tree v6
    (and the same with --tree v5; relink also takes --tree v7, whose C link scripts were v10's copies
    in places: v7-c-bins-raw / v7-c-bins in the Makefile).  Each is skipped where the tree has the edit already, so both can
    run again on a regenerated tree; the tree READMEs list them after port_hand_edits.py.
"""
import argparse
import collections
import glob
import json
import os
import re
import shutil
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NM = os.path.join(os.environ.get("PROJECTS_ROOT", os.path.expanduser("~/compartilhado")),
                  "llvm-project", "build", "bin", "llvm-nm")
BASE, END = 0xE00000, 0x1000000
BYTE_ROW = re.compile(r'^\t\.byte\t(.*)$')


def rd(p):
    return open(p, "rb").read().decode("latin-1")


def wr(p, s):
    open(p, "wb").write(s.encode("latin-1"))


def elf_syms(tree):
    out = subprocess.run([NM, "--defined-only", os.path.join(ROOT, "rebuilt_ROMs", "kn5000_%s_program.llvm.elf" % tree)],
                         capture_output=True, text=True, check=True).stdout
    by_name, by_addr = {}, {}
    for ln in out.split("\n"):
        p = ln.split()
        if len(p) != 3 or p[1] not in "tT" or p[2].startswith((".L", "__")):
            continue
        a = int(p[0], 16)
        by_name.setdefault(p[2], a)
        by_addr.setdefault(a, p[2])
    return by_name, by_addr


def build_ok(tree):
    r = subprocess.run(["make", "-s", "rebuilt_ROMs/kn5000_%s_program.llvm.rom" % tree],
                       cwd=ROOT, capture_output=True, text=True)
    a = os.path.join(ROOT, "rebuilt_ROMs", "kn5000_%s_program.llvm.rom" % tree)
    b = os.path.join(ROOT, "original_ROMs", "kn5000_%s_program.rom" % tree)
    return r.returncode == 0 and open(a, "rb").read() == open(b, "rb").read(), r.stderr[-3000:]


def tree_files(tree):
    return sorted(glob.glob(os.path.join(ROOT, tree, "maincpu", "**", "*.s"), recursive=True))


# ----------------------------------------------------------------------------------------------- rows
def rows(tree, labels):
    _, by_addr = elf_syms(tree)
    backup, done = {}, []
    for lab in labels:
        hits = [p for p in tree_files(tree) if re.search(r'^%s:\s*$' % re.escape(lab), rd(p), re.M)]
        if len(hits) != 1:
            print("%-36s %s: label line found in %d files -- skipped" % (lab, tree, len(hits)))
            continue
        p = hits[0]
        L = rd(p).split("\n")
        i = next(k for k, ln in enumerate(L) if re.match(r'^%s:\s*$' % re.escape(lab), ln))
        j = i + 1
        while j < len(L) and L[j].startswith(";"):
            j += 1
        k = j
        vals = []
        while k < len(L) and BYTE_ROW.match(L[k]) and ";" not in L[k]:
            vals += [int(x, 0) for x in BYTE_ROW.match(L[k]).group(1).split(",")]
            k += 1
        if k == j:
            print("%-36s %s: no .byte rows after the label (already spelled?) -- skipped" % (lab, tree))
            continue
        if len(vals) % 4:
            print("%-36s %s: %d bytes, not whole words -- skipped" % (lab, tree, len(vals)))
            continue
        words = [int.from_bytes(bytes(vals[n:n + 4]), "little") for n in range(0, len(vals), 4)]
        bad = [w for w in words if w and w not in by_addr]
        if bad:
            print("%-36s %s: %d word(s) with no label at the target (%s) -- skipped"
                  % (lab, tree, len(bad), " ".join("0x%06x" % w for w in bad[:6])))
            continue
        new = ["\t.long\t%s" % (by_addr[w] if w else "0") for w in words]
        keep = [ln for ln in L[i + 1:j] if not ln.startswith("; TODO(port): ")]
        backup.setdefault(p, rd(p))
        L[i + 1:k] = keep + new
        wr(p, "\n".join(L))
        done.append((lab, len(words), os.path.relpath(p, ROOT)))
    if not backup:
        print("rows %s: nothing to do" % tree)
        return
    ok, err = build_ok(tree)
    if not ok:
        for p, s in backup.items():
            wr(p, s)
        sys.exit("rows %s: not byte-identical after the edit; files restored\n%s" % (tree, err))
    for lab, n, f in done:
        print("%-36s %s: %d words spelled by name (%s)" % (lab, tree, n, f))
    print("rows %s: byte-identical" % tree)


# --------------------------------------------------------------------------------------------- relink
def write_json(path, d):
    """In port_maincpu_version.py's layout: one bin per line, sorted."""
    with open(path, "w") as fh:
        fh.write("{\n" + ",\n".join('  %s: %s' % (json.dumps(k), json.dumps(v, separators=(",", ":")))
                                    for k, v in sorted(d.items())) + "\n}\n")


LD_LINE = re.compile(r'^([A-Za-z_]\w*)(\s*=\s*)0x([0-9A-Fa-f]+);', re.M)


def divergence(raw0, need, size):
    """One bin's divergence entry, by the porter's rule (port_maincpu_version.py c_divergence): a 4-byte
    aligned word that is a ROM address on both sides is a moved pointer, any other differing byte raw."""
    src = bytearray(raw0) + b"\x00" * max(0, size - len(raw0))
    relocs, raw, o = [], {}, 0
    while o < size:
        if src[o] == need[o]:
            o += 1
            continue
        a4 = o - o % 4
        if a4 + 4 <= size:
            v0, v1 = (int.from_bytes(x[a4:a4 + 4], "little") for x in (src, need))
            if BASE <= v0 < BASE + 0x200000 and BASE <= v1 < BASE + 0x200000:
                relocs.append([a4, v1 - v0])
                o = a4 + 4
                continue
        raw[str(o)] = need[o]
        o += 1
    return dict(size=size, reloc=relocs, raw=raw)


def debt(e):
    return len(e.get("raw", {})) + len(e.get("reloc", []))


def relink(tree):
    by_name, _ = elf_syms(tree)
    gen = os.path.join(ROOT, tree, "maincpu", "includes", "generated")
    jpath = os.path.join(ROOT, tree, "maincpu", "includes", "%s_c_divergence.json" % tree)
    old_json = open(jpath).read()
    cdiv = json.loads(old_json)
    bins = sorted(glob.glob(os.path.join(gen, "*.bin")))
    # the bytes the image needs: each bin as the build left it (patched where the json says so), but
    # only where a `.incbin "includes/generated/<bin>", off, len` of the tree puts them in the image;
    # a byte no .incbin takes is don't-care (ctlonly.c's 36 handler words: the tree spells
    # Scoop_StaticOpHandlerTable as `.long` lines), so it takes whatever the relinked bin holds
    needed, used = {}, collections.defaultdict(set)
    inc = re.compile(r'\.incbin\s+"includes/generated/([^"]+)"\s*(?:,\s*(0x[0-9A-Fa-f]+|\d+)\s*(?:,\s*(0x[0-9A-Fa-f]+|\d+))?)?')
    for f in tree_files(tree):
        for m in inc.finditer(rd(f)):
            b = m.group(1)
            p_ = os.path.join(gen, b)
            off = int(m.group(2), 0) if m.group(2) else 0
            ln = int(m.group(3), 0) if m.group(3) else (os.path.getsize(p_) - off if os.path.exists(p_) else 0)
            used[b].update(range(off, off + ln))
    for p in bins:
        b = os.path.basename(p)
        d = open(p, "rb").read()
        needed[b] = d[:cdiv[b]["size"]] if b in cdiv else d
    lds = sorted(glob.glob(os.path.join(ROOT, tree, "maincpu", "**", "*_link.ld"), recursive=True))
    old_ld, kept, refused = {}, [], []

    def make(target):
        return subprocess.run(["make", "-s", target], cwd=ROOT, capture_output=True, text=True)

    def restore(msg):
        for p, s in old_ld.items():
            wr(p, s)
        open(jpath, "w").write(old_json)
        make("%s-c-bins-raw" % tree)
        make("%s-c-bins" % tree)
        sys.exit(msg)

    for p in lds:
        s = rd(p)
        n = [0]

        def fix(m):
            v = int(m.group(3), 16)
            a = by_name.get(m.group(1))
            if a is None or not (BASE <= v < END) or a == v:
                return m.group(0)
            n[0] += 1
            return "%s%s0x%08X;" % (m.group(1), m.group(2), a)
        s2 = LD_LINE.sub(fix, s)
        if s2 == s:
            continue
        before = {b: os.path.getmtime(b) for b in bins}
        wr(p, s2)
        r = make("%s-c-bins-raw" % tree)
        if r.returncode:
            old_ld[p] = s
            restore("relink %s: the C bins did not build with %s; restored\n%s" % (tree, p, r.stderr[-3000:]))
        rebuilt = [os.path.basename(b) for b in bins if os.path.getmtime(b) != before[b]]
        new = {}
        for b in rebuilt:
            e = cdiv.get(b, dict(size=len(needed[b]), reloc=[], raw={}))
            raw1 = open(os.path.join(gen, b), "rb").read()
            need = bytearray(needed[b])
            for o in range(min(len(need), len(raw1))):
                if o not in used[b]:
                    need[o] = raw1[o]
            new[b] = (debt(e), divergence(raw1, bytes(need), e["size"]))
        rel = os.path.relpath(p, ROOT)
        if any(debt(d) > o for o, d in new.values()):
            wr(p, s)                       # this script's names would make a bin worse: keep it as it was
            make("%s-c-bins-raw" % tree)
            refused.append((rel, n[0], {b: (o, debt(d)) for b, (o, d) in new.items()}))
            continue
        old_ld[p] = s
        for b, (o, d) in new.items():
            raw0 = open(os.path.join(gen, b), "rb").read()
            if d["reloc"] or d["raw"] or d["size"] != len(raw0):
                cdiv[b] = d
            else:
                cdiv.pop(b, None)
        kept.append((rel, n[0], {b: (o, debt(d)) for b, (o, d) in new.items()}))
    if not old_ld:
        print("relink %s: nothing relinked (%d script(s) refused)" % (tree, len(refused)))
    write_json(jpath, cdiv)
    r = make("%s-c-bins" % tree)
    ok, err = build_ok(tree) if not r.returncode else (False, r.stderr[-3000:])
    if not ok:
        restore("relink %s: not byte-identical after the edit; restored\n%s" % (tree, err))
    for what, rows_ in (("relinked", kept), ("REFUSED (a bin would carry more patched bytes)", refused)):
        for rel, n, per in rows_:
            print("%-62s %3d address(es) %s; %s" % (rel, n, what, ", ".join(
                "%s %d -> %d" % (b, o, d) for b, (o, d) in sorted(per.items()))))
    print("relink %s: byte-identical; divergence entries %d -> %d" % (
        tree, sum(debt(e) for e in json.loads(old_json).values()), sum(debt(e) for e in cdiv.values())))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("what", choices=("rows", "relink"))
    ap.add_argument("--tree", required=True, help="v6 or v5")
    ap.add_argument("labels", nargs="*")
    a = ap.parse_args()
    if a.tree not in ("v6", "v5") and not (a.tree == "v7" and a.what == "relink"):
        sys.exit("--tree v6 or v5 (relink also v7, whose json apply_v7_c_divergence.py applies)")
    rows(a.tree, a.labels) if a.what == "rows" else relink(a.tree)


if __name__ == "__main__":
    main()
