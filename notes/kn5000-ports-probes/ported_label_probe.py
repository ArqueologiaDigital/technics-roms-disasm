#!/usr/bin/env python3
r"""Does every label the ported KN5000 trees (v6, v5) inherited from v7 stand on the thing it names?

QUESTION THIS ANSWERS
    scripts/converters/port_maincpu_version.py made v6/maincpu from v7/maincpu and v5 from v6, keeping
    v7's label names.  The byte gate proves the image, not the names, and
    scripts/analysis/check_ported_labels.py (a byte-window comparison) cannot see a name moved onto the
    next of a run of look-alike procedures: the language-check procedures `cp xbc, EVT_GET_LANGUAGE_PTR /
    jr nz / lda xhl, (Table) / ret` differ only in the table they load.  The first such shift (v5's Yoko
    ApFunction language checks, scripts/renaming/rename_v5_langcheck_shift.sed) was found by reading v5's
    own ApFunction table and its name table.  This probe does that for every table the firmware itself
    gives names or slots, in every tree, and adds two checks that need no firmware names.

FOUR CHECKS (each compares tree T in v6 / v5 with v7, by name)
  registry  Every registered NAKA table (nakarest_objtab_map.Map: RegObjTabl calls, read from the ROM
            dump): Function / ApFunction / MainFunction tables with their name table (slot + 0x300), the
            Viewable record tables with their ResName table, and the Class tables (record + class name).
            Each entry is keyed by (kind, slot, firmware name, occurrence); the v7 labels at the entry's
            v7 address must be among T's labels at the same key's T address.
  ptrtab    Every run of >= 2 aligned 32-bit words in v7's ROM, starting at a v7 label, that are all
            addresses of v7 labels (a pointer table, wherever it is spelled: `.long`, C data, `.byte`),
            each label inside a run starting a table of its own up to the next one, labels inside a
            registered table (and its end marker) left out: the registry check reads those by name.  Entry k of the run in T (at T's address of the same table label, up to T's next
            labelled address) must carry the labels v7's entry k carries.  From the first T word that
            is not a label address of T the table is not judged (it changed shape).
  body      For every label both trees define, the set of labels the instructions of its body name (up
            to the next non-local label), read from the sources.  A body that names as many labels as
            v7's body of the same label, all defined in both trees, but other ones, is a MISMATCH: the
            label, or a label it names, stands on another thing.  A body whose names the port dropped
            or added is a code change ("changed") and is not judged.
  bytes     scripts/analysis/check_ported_labels.py's "misplaced" list (byte windows found once
            elsewhere within 8 KB), for the record: it is an upper bound and needs reading.

  A result row is "MISMATCH" when a v7 name stands on another thing in T (a shifted name),
  "UNLABELLED" / "DROPPED" when T's thing has only a name of its own where v7's name could stand
  (the port left the name out), "ok" otherwise; the counts are the answer.  The goal state is 0
  MISMATCH rows in registry, ptrtab and body.

RUN (repository root; needs v7, v6, v5 built: make all, or make gate)
    python3 notes/kn5000-ports-probes/ported_label_probe.py [--tree v6|v5] [--list FILE]
    Exit status 1 when any registry / ptrtab / body mismatch is left.
"""
import argparse
import bisect
import collections
import glob
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "analysis"))
import nakarest_objtab_map as nom  # noqa: E402

BASE, SIZE = 0xE00000, 0x200000
FUNC = {0x1600001: "Function", 0x1600002: "ApFunction", 0x1600003: "MainFunction"}
FAMILY = re.compile(r"^(.*_(?:Skip|Join|Loop|Return|Epilogue|Helper|Done|Case|Next|Exit|Fmt\w*?_|Str_\w+?_))(\d*)$")
PINNED = set()          # names a registry or pointer-table entry found right (filled by the checks)


def labels(v):
    """address -> set of non-local ROM labels, name -> address (llvm-nm `t`)."""
    out = subprocess.run([os.path.join(nom.LLVM, "llvm-nm"), "--defined-only",
                          os.path.join(ROOT, "rebuilt_ROMs", "kn5000_%s_program.llvm.elf" % v)],
                         capture_output=True, text=True, check=True).stdout
    by_addr, by_name = collections.defaultdict(set), {}
    for ln in out.split("\n"):
        p = ln.split()
        if len(p) == 3 and p[1] in "tT" and not p[2].startswith((".L", "__")):
            a = int(p[0], 16)
            if BASE <= a < BASE + SIZE:
                by_addr[a].add(p[2])
                by_name.setdefault(p[2], a)
    return by_addr, by_name


def verdict(n7, nt, lab7, labt):
    """MISMATCH: T's thing carries a name v7 gives to something else, or v7's name stands elsewhere
    in T (a shifted name).  UNLABELLED: T has none of v7's names anywhere and gives the thing no
    v7 name (a label the port dropped although the thing is there)."""
    if nt & set(lab7[1]) or any(n in labt[1] for n in n7):
        return "MISMATCH"
    return "UNLABELLED"


# ------------------------------------------------------------------------------------------ registry
def registry(m):
    """key -> address of every named registered thing of map m."""
    out = {}
    seen = collections.Counter()
    by_slot = collections.defaultdict(list)
    for r in m.regs:
        by_slot[(r["cls"], r["slot"])].append(r)

    def put(kind, slot, name, a):
        k = (kind, slot, name)
        seen[k] += 1
        out[k + (seen[k],)] = a

    for r in m.regs:
        cls, slot = r["cls"], r["slot"]
        if not m.inrom(r["table"]) or slot >= 0x300 and nom.CLASS.get(cls) != "Class":
            continue
        kind = FUNC.get(cls) or nom.CLASS.get(cls)
        if kind in FUNC.values() or kind == "Viewable":
            names = by_slot.get((cls if kind != "Viewable" else 0x160000F, slot + 0x300))
            if not names:
                continue
            nt = names[0]
            ents = m.entries(r)
            for k, a in enumerate(ents):
                if k >= nt["count"]:
                    break
                p = m.u32(nt["table"] + 4 * k)
                nm_ = m.string_at(p) if m.inrom(p) else "#%d" % k
                if kind == "Viewable":
                    put("view", slot, nm_, a)
                else:
                    put(kind, slot, nm_, a)
        elif kind == "Class":
            for k in range(r["count"]):
                a = r["table"] + 24 * k
                np_ = m.u32(a + 12)
                nm_ = m.string_at(np_) if m.inrom(np_) else "#%d" % k
                put("classrec", slot, nm_, a)
                put("classproc", slot, nm_, m.u32(a))
    return out


def check_registry(ref, t, lab_ref, lab_t):
    rows, cnt = [], collections.Counter()
    for key, a7 in sorted(ref.items(), key=lambda kv: (kv[0][0], kv[0][1], kv[0][2], kv[0][3])):
        if key not in t:
            cnt["only-v7"] += 1
            continue
        at = t[key]
        n7, nt = lab_ref[0].get(a7, set()), lab_t[0].get(at, set())
        if not n7:
            cnt["unlabelled-in-v7"] += 1
            continue
        if n7 & nt:
            cnt["ok"] += 1
            PINNED.update(n7 & nt)
            continue
        kind = verdict(n7, nt, lab_ref, lab_t)
        cnt[kind] += 1
        where = ", ".join("%s@0x%06x" % (n, lab_t[1][n]) for n in sorted(n7) if n in lab_t[1]) or "not defined"
        rows.append(dict(check="registry", kind=kind, n7=n7, nt=nt, a7=a7, at=at,
                         text="%s slot 0x%x %r #%d: v7 0x%06x %s; T 0x%06x carries %s; v7 name(s) in T: %s"
                         % (key[0], key[1], key[2], key[3], a7, "/".join(sorted(n7)), at,
                            "/".join(sorted(nt)) or "(no label)", where)))
    cnt["only-T"] = len(set(t) - set(ref))
    return cnt, rows


# -------------------------------------------------------------------------------------------- ptrtab
def rom(v):
    return open(os.path.join(ROOT, "original_ROMs", "kn5000_%s_program.rom" % v), "rb").read()


def u32(r, a):
    return int.from_bytes(r[a - BASE:a - BASE + 4], "little")


def check_ptrtab(r7, rt, lab7, labt, registered):
    rows, cnt = [], collections.Counter()
    a7s, ats = sorted(lab7[0]), sorted(labt[0])

    def room(addrs, a):
        """words from a to the next labelled address"""
        i = bisect.bisect_right(addrs, a)
        return ((addrs[i] if i < len(addrs) else BASE + SIZE) - a) // 4
    run_at = set()                     # addresses inside a run already met
    for name, a in sorted(lab7[1].items(), key=lambda kv: kv[1]):
        if name not in labt[1]:
            continue
        i = bisect.bisect_right(registered, (a, BASE + SIZE)) - 1
        if i >= 0 and registered[i][0] <= a < registered[i][1]:
            continue                   # inside a registered table: the registry check reads it by name
        # the run of label addresses starting at a (it may run past later labels: one table)
        ents = []
        x = a
        while x + 4 <= BASE + SIZE:
            w = u32(r7, x)
            if w not in lab7[0]:
                break
            ents.append(w)
            x += 4
        ents = ents[:room(a7s, a)]     # a label inside the run starts a table of its own
        if len(ents) < 2 and not (ents and a - 4 in run_at):
            continue
        run_at.update(range(a, a + 4 * len(ents), 4))
        b = labt[1][name]
        for k, w7 in enumerate(ents):
            wt = u32(rt, b + 4 * k)
            if wt not in labt[0]:
                cnt["not-judged"] += 1
                break                  # T's table is shorter, or changed shape here
            n7, nt = lab7[0][w7], labt[0][wt]
            if n7 & nt:
                cnt["ok"] += 1
                PINNED.update(n7 & nt)
                continue
            kind = verdict(n7, nt, lab7, labt)
            cnt[kind] += 1
            where = ", ".join("%s@0x%06x" % (n, labt[1][n]) for n in sorted(n7) if n in labt[1]) or "not defined"
            rows.append(dict(check="ptrtab", kind=kind, n7=n7, nt=nt, a7=w7, at=wt, table=name, k=k,
                             text="%s[%d]: v7 -> %s; T -> 0x%06x %s; v7 name(s) in T: %s"
                             % (name, k, "/".join(sorted(n7)), wt, "/".join(sorted(nt)), where)))
    return cnt, rows


# ---------------------------------------------------------------------------------------------- body
class Content:
    """Byte windows of v7 and T (`window` bytes or up to v7's next label) compared with ROM pointers
    translated (check_ported_labels' rule).  32 bytes to decide between two places of one name (12
    took a pointer table for another); 12 where a table slot already names the thing."""

    def __init__(self, lab7, labt, r7, rt):
        self.r7, self.rt = r7, rt
        self.lab7, self.labt = lab7, labt
        self.a7s = sorted(lab7[0])
        pair = collections.defaultdict(collections.Counter)
        for n in set(lab7[1]) & set(labt[1]):
            pair[lab7[1][n]][labt[1][n]] += 1
        self.move = {a: c.most_common(1)[0][0] for a, c in pair.items()}

    def same(self, a7, at, window=32):
        k = bisect.bisect_right(self.a7s, a7)
        n = min(window, (self.a7s[k] if k < len(self.a7s) else BASE + SIZE) - a7)
        if n < 1:
            return False
        b = bytearray(self.r7[a7 - BASE:a7 - BASE + n])
        o = 0
        while o < n - 2:
            for w in (4, 3):
                if o + w <= n:
                    v = int.from_bytes(b[o:o + w], "little")
                    if v in self.move and (w == 4 or b[o + 2] >= 0xE0):
                        b[o:o + w] = self.move[v].to_bytes(w, "little")
                        o += w - 1
                        break
            o += 1
        return bytes(b) == self.rt[at - BASE:at - BASE + n]


LABEL_DEF = re.compile(rb"^([A-Za-z_][\w$]*):")
IDENT = re.compile(rb"[A-Za-z_.][\w.$]*")
DIRECTIVE_SKIP = (b".incbin", b".include", b".section", b".org", b".align", b".set", b".equ", b".global",
                  b".globl", b".macro", b".endm", b".if", b".else", b".endif", b".ifndef", b".ifdef")


def bodies(v, known):
    """label -> frozenset of known labels its body names (the lines up to the next non-local label)."""
    out = {}
    for f in sorted(glob.glob(os.path.join(ROOT, v, "maincpu", "**", "*.s"), recursive=True)):
        cur, refs = None, set()
        for ln in open(f, "rb").read().split(b"\n"):
            code = ln.split(b";")[0]
            m = LABEL_DEF.match(code)
            if m:
                if cur is not None:
                    out[cur] = frozenset(refs)
                cur, refs = m.group(1).decode(), set()
                code = code[m.end():]
            s = code.strip()
            if not s or cur is None or s.startswith(DIRECTIVE_SKIP):
                continue
            for tok in IDENT.findall(s.split(None, 1)[1] if len(s.split(None, 1)) > 1 else b""):
                t = tok.decode()
                if t in known and t != cur:
                    refs.add(t)
        if cur is not None:
            out[cur] = frozenset(refs)
    return out


def check_body(b7, bt, names7, namest, fixed=frozenset(), content=None):
    """Shifted names found from the bodies that name them.  For each body of a label both trees define
    that names exactly one label other than v7's body of the same label does (T names r_T where v7
    names r_7, everything else equal; r_T defined in T, r_7 in v7), r_T gets a vote "should be r_7";
    where several differ (as many on each side), each r_T is paired with the one r_7 whose bytes its
    place holds (`content`), and votes only when every one pairs.  r_T is a MISMATCH when every T body that names it and has a v7 twin votes for the same r_7
    and none of those v7 twins names r_T itself.  DROPPED when T does not define r_7 (a v7 name the
    port left out; T's thing has a name of its own).  When T defines r_7 too, the bytes decide
    (`content`): a MISMATCH (the name stands on another thing) when r_T's place holds v7's bytes of
    r_7 and r_7's place does not, a code change when it is the other way round, a MISMATCH also when
    neither decides but both are numbered block labels (_SkipN, _JoinN ...: their numbers mean
    nothing), and UNDECIDED otherwise (listed for reading).  Names in `fixed` (those of the registry and pointer
    table rows: a misplaced procedure votes for the wrong thing) neither vote nor are voted on.  The other differing bodies are code changes ("changed")."""
    rows, cnt = [], collections.Counter()
    votes = collections.defaultdict(collections.Counter)
    against = collections.Counter()
    referrers = collections.Counter()
    for n in sorted(set(b7) & set(bt)):
        s7, st = b7[n], bt[n]
        for r in st:
            referrers[r] += 1
            if r in s7:
                against[r] += 1
        if not s7 or s7 == st:
            cnt["ok" if s7 else "empty"] += 1
            continue
        dt, d7 = st - s7, s7 - st
        if not (dt and len(dt) == len(d7) and dt <= namest and d7 <= names7) or n in fixed:
            cnt["changed"] += 1
        elif len(dt) == 1:
            votes[next(iter(dt))][next(iter(d7))] += 1
        elif content is not None:
            # several names differ: pair each with the one v7 name whose bytes its place holds
            pairs = {}
            for x in dt:
                m = [y for y in d7 if content.same(content.lab7[1][y], content.labt[1][x])]
                if len(m) == 1:
                    pairs[x] = m[0]
            if len(pairs) == len(dt) and len(set(pairs.values())) == len(dt):
                for x, y in pairs.items():
                    votes[x][y] += 1
            else:
                cnt["changed"] += 1
        else:
            cnt["changed"] += 1
    for r, c in sorted(votes.items()):
        (r7, n), = c.most_common(1)
        if len(c) == 1 and n == referrers[r] and not against[r] and r not in fixed:
            if r7 not in namest:
                kind = "DROPPED"
            elif content is None:
                kind = "MISMATCH"
            else:
                # T defines r7 too: which of the two places holds v7's bytes of r7?
                c_at = content.same(content.lab7[1][r7], content.labt[1][r])
                c_b = content.same(content.lab7[1][r7], content.labt[1][r7])
                if c_at and not c_b:
                    kind = "MISMATCH"
                elif c_b and not c_at:
                    kind = "changed"           # T's r7 is v7's: the code calls another thing now
                elif FAMILY.match(r) and FAMILY.match(r7):
                    kind = "MISMATCH"          # numbered block labels: the bodies decide
                else:
                    kind = "UNDECIDED"
            cnt[kind] += 1
            if kind == "changed":
                continue
            rows.append(dict(check="body", kind=kind, old=r, new=r7, n=n,
                             text="%s should be %s (%d of %d T bodies naming it say so)" % (r, r7, n, referrers[r])))
        else:
            cnt["changed"] += sum(c.values())
    return cnt, rows


# ---------------------------------------------------------------------------------------------- main
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", choices=("v6", "v5"), action="append")
    ap.add_argument("--list", metavar="FILE", help="write every MISMATCH row to FILE")
    a = ap.parse_args()
    trees = a.tree or ["v6", "v5"]
    m7 = nom.Map("v7")
    lab7 = labels("v7")
    reg7 = registry(m7)
    r7 = rom("v7")
    b7 = bodies("v7", set(lab7[1]))
    allrows, bad = [], 0
    for t in trees:
        mt = nom.Map(t)
        labt = labels(t)
        reg = sorted((r["table"], r["table"] + (24 if r["cls"] == 0x1600004 else 4) * (r["count"] + 1))
                     for r in m7.regs if m7.inrom(r["table"]))
        rc = check_registry(reg7, registry(mt), lab7, labt)
        pc = check_ptrtab(r7, rom(t), lab7, labt, reg)
        suspect = set()
        for r in rc[1] + pc[1]:
            suspect |= set(r["n7"]) | set(r["nt"])
        bc = check_body(b7, bodies(t, set(labt[1])), set(lab7[1]), set(labt[1]), suspect,
                        Content(lab7, labt, r7, rom(t)))
        for what, (cnt, rows) in (("registry", rc), ("ptrtab", pc), ("body", bc)):
            print("%s %-8s %s" % (t, what, ", ".join("%s %d" % kv for kv in sorted(cnt.items()))))
            bad += cnt["MISMATCH"]
            allrows += ["%s %s %s %s" % (t, r["check"], r["kind"], r["text"]) for r in rows]
    for r in allrows:
        print(r)
    if a.list:
        open(a.list, "w").write("\n".join(allrows) + "\n")
    print("MISMATCH rows: %d" % bad)
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
