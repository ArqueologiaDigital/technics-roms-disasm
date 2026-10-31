#!/usr/bin/env python3
r"""Put the names a ported KN5000 main-program tree (v6, v5) carried over from v7 back on their things.

QUESTION THIS ANSWERS
    notes/kn5000-ports-probes/ported_label_probe.py finds v7 names the porter
    (scripts/converters/port_maincpu_version.py) left on the wrong thing: the firmware's own
    registration and name tables (registry), its pointer tables (ptrtab), and the bodies that name a
    label (body).  Which renames and new labels put every such name back, and does the image stay
    byte-identical?  This script computes them from the probe's evidence, applies them, rebuilds, and
    repeats until the probe finds nothing more (a rename can uncover the next one: once a procedure
    carries its own name, its `_ReturnZero` is found by its body).

WHAT IT DOES, PER ROUND
  1. registry / ptrtab rows (MISMATCH or UNLABELLED): T's thing at address `at` should carry v7's
     name(s) n7.  A MISMATCH is accepted only when T's bytes at `at` equal v7's bytes at n7's address
     (12 bytes or up to v7's next label, ROM pointers translated through the labels both trees
     define; the slot already names the thing); a table whose label is what moved (its entries are right by content) is left to a hand
     edit and reported.  An UNLABELLED entry (T's thing has only a name of T's own, the porter's
     `_Data` / `_Skip` ...) takes v7's name by its table slot, even where its code changed.
  2. body rows, once no registry / ptrtab row is left: name old should be new (every T body that
     names it says so).  A DROPPED row (new is a v7 name T does not define) is accepted only by
     content, as in 1.
  3. then, when nothing above is left: a label whose T body names exactly what v7's body of one other
     label names, and whose bytes are that label's (by content), takes that label's name: the
     procedure itself stood one place off (the referred-to names being right).  Not for names a
     table entry has found right (probe.PINNED).
  Each accepted name goes on its address: the wrong name standing there is renamed to it (globally,
  as a word outside quoted strings, in every .s file of the tree and in port_dropped_labels.txt), or, where the thing has no
  name, a label line is inserted before the line that emits its first byte.  All renames of a round
  are made at once through temporary names, so chains and swaps are fine.  A name that would end up
  defined twice, because its old place keeps it, is decided by content (which of the two places has
  v7's bytes); a numbered block label (_SkipN, _JoinN ...) left on its old place takes the family's
  next free number; anything else is not given and is reported.
  0. first, the HAND edits below (shifts the evidence leaves UNDECIDED, read by hand).
  4. `; port: v7's label X is not in T ...` lines and port_dropped_labels.txt rows for names the tree
     now defines are dropped.
  5. The tree is rebuilt and compared with its dump; on any difference every file is restored.
  The C link scripts are not edited here: the C data names v7's things, and
  scripts/tools/port_symbolize_pointers.py relink gives each script line its name's address afterwards.

RUN (repository root; v7 and the tree built, rebuilt_ROMs/kn5000_<tree>_program.llvm.{elf,rom})
    python3 scripts/tools/port_fix_label_shifts.py --tree v6 [--dry-run] [--rounds N]
    python3 scripts/tools/port_symbolize_pointers.py relink --tree v6
    Idempotent: on a tree the probe passes it does nothing.
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
sys.path.insert(0, os.path.join(ROOT, "notes", "kn5000-ports-probes"))
sys.path.insert(0, os.path.join(ROOT, "scripts", "converters"))
import ported_label_probe as probe  # noqa: E402

BASE, SIZE = probe.BASE, probe.SIZE
FAMILY = probe.FAMILY


def rd(p):
    return open(p, "rb").read().decode("latin-1")


def wr(p, s):
    open(p, "wb").write(s.encode("latin-1"))


def tree_files(tree):
    fs = sorted(glob.glob(os.path.join(ROOT, tree, "maincpu", "**", "*.s"), recursive=True))
    d = os.path.join(ROOT, tree, "maincpu", "port_dropped_labels.txt")
    return fs + ([d] if os.path.exists(d) else [])


def build_ok(tree):
    r = subprocess.run(["make", "-s", "rebuilt_ROMs/kn5000_%s_program.llvm.rom" % tree], cwd=ROOT,
                       capture_output=True, text=True)
    a = os.path.join(ROOT, "rebuilt_ROMs", "kn5000_%s_program.llvm.rom" % tree)
    b = os.path.join(ROOT, "original_ROMs", "kn5000_%s_program.rom" % tree)
    return r.returncode == 0 and open(a, "rb").read() == open(b, "rb").read(), r.stderr[-3000:]


# Edits the evidence cannot decide by itself (the probe's UNDECIDED rows that are shifts), read by hand.
# Each is (label to delete or None, [(old, new) renames]); skipped where `old` is gone already.
HAND = [
    # VoiceTable_AdvanceWritePos (v7: `ld xhl, xwa / ld wa, (14568) / inc 1, wa / ld (14568), wa /
    # cp wa, 255 / jr c, RhythmParam_Setup`) is, in v6 and v5, the block the port called
    # VoiceTable_ResolveReadAddr_Skip (`incw 1, (0x38cc) / cpw (0x38cc), 255 / jr c, RhythmParam_Setup`,
    # the same counter bump spelled as memory operands), the one VoiceScan_WriteLoop names where v7's
    # names VoiceTable_AdvanceWritePos.  The port had left that name on a `pop xde` inside
    # CmpNcpTtl_TableDispatch_OnToItemNext, which nothing names.
    ("VoiceTable_AdvanceWritePos", [("VoiceTable_ResolveReadAddr_Skip", "VoiceTable_AdvanceWritePos")]),
]


def hand(tree):
    """-> (deletions, renames) still to do in the tree"""
    txt = "".join(rd(p) for p in tree_files(tree) if p.endswith(".s"))
    dels, ren = [], {}
    for d, rs in HAND:
        todo = [(o, n) for o, n in rs if re.search(r"^%s:" % re.escape(o), txt, re.M)]
        if todo:
            if d:
                dels.append(d)
            ren.update(todo)
    return dels, ren


def plan(tree, ev):
    """-> (renames {old: new}, inserts {address: name}, notes [str], names defined twice); the first
    phase that has anything to do wins: tables, then bodies, then bodies of another label."""
    lab7, labt, rows = ev["lab7"], ev["labt"], ev["rows"]
    content = probe.Content(lab7, labt, ev["r7"], ev["rt"])
    notes = []
    want = {}                                   # T address -> v7 name
    for r in rows:
        if r["check"] in ("registry", "ptrtab"):
            # an UNLABELLED entry carries only the tree's own name (the porter's _Data / _Skip ...): the
            # table slot names it even where its code changed; a MISMATCH must match by content
            if r["kind"] != "UNLABELLED" and not content.same(r["a7"], r["at"], 12):
                notes.append("not by content, left for a hand edit: %s %s" % (r["check"], r["text"]))
                continue
            names = sorted(r["n7"])
            name = names[0] if len(names) == 1 else min(names, key=lambda x: (x not in labt[1], len(x)))
            if want.get(r["at"], name) != name:
                notes.append("two names wanted at 0x%06x: %s, %s" % (r["at"], want[r["at"]], name))
                continue
            want[r["at"]] = name
    res = resolve(want, lab7, labt, content, notes)
    if res[0] or res[1]:
        return res
    want = {}
    for r in rows:
        if r["check"] != "body":
            continue
        at = labt[1][r["old"]]
        # a dropped v7 name is given back only where T's bytes are v7's (by content)
        if r["kind"] == "UNDECIDED" or r["kind"] == "DROPPED" and not content.same(lab7[1][r["new"]], at):
            notes.append("not by content, not given: %s" % r["text"])
            continue
        want.setdefault(at, r["new"])
    res = resolve(want, lab7, labt, content, notes)
    if res[0] or res[1]:
        return res
    want = {}
    for r in rows:
        if r["check"] == "body-of" and content.same(lab7[1][r["new"]], labt[1][r["old"]]):
            want.setdefault(labt[1][r["old"]], r["new"])
    return resolve(want, lab7, labt, content, notes)


def resolve(want, lab7, labt, content, notes):
    v7names = set(lab7[1])
    renames, inserts = {}, {}
    for at, name in sorted(want.items()):
        cur = labt[0].get(at, set())
        if name in cur:
            continue
        wrong = sorted(n for n in cur if n in v7names) or sorted(cur)
        wrong = [n for n in wrong if n not in renames]
        if wrong:
            renames[wrong[0]] = name
        else:
            inserts[at] = name
    # a name given to a thing while it still stands on another one, which nothing renames: a numbered
    # block label (the porter's _SkipN / _JoinN ... of a family whose numbers mean nothing) takes the
    # family's next free number; any other name is not given (reported)
    taken = set(lab7[1]) | set(labt[1]) | set(renames.values()) | set(inserts.values())
    for _ in range(3):
        final = collections.Counter(renames.get(n, n) for n in labt[1])
        final.update(inserts.values())
        dup = sorted(n for n, c in final.items() if c > 1)
        if not dup:
            break
        for n in dup:
            m = FAMILY.match(n)
            incoming = [o for o, x in renames.items() if x == n]
            if n in labt[1] and n not in renames and incoming and n in lab7[1]:
                # decide by content which of the two things is v7's n
                c_at = content.same(lab7[1][n], labt[1][incoming[0]])
                c_b = content.same(lab7[1][n], labt[1][n])
                if c_b and not c_at:
                    del renames[incoming[0]]
                    notes.append("not given, by content %s stays where it is: %s -> %s" % (n, incoming[0], n))
                    continue
                if c_at and not c_b and not m:
                    notes.append("not given, %s is v7's by content but its old place has no name to take: "
                                 "%s -> %s" % (n, incoming[0], n))
                    del renames[incoming[0]]
                    continue
            if n in labt[1] and n not in renames and m:
                k = 2
                while "%s%d" % (m.group(1), k) in taken:
                    k += 1
                renames[n] = "%s%d" % (m.group(1), k)
                taken.add(renames[n])
                notes.append("%s stood on another thing too: that one is %s now" % (n, renames[n]))
            else:
                for o in [o for o, x in renames.items() if x == n]:
                    del renames[o]
                    notes.append("not given, %s is defined elsewhere and not moved: %s -> %s" % (n, o, n))
                for a_ in [a_ for a_, x in inserts.items() if x == n]:
                    del inserts[a_]
                    notes.append("not given, %s is defined elsewhere and not moved: new label at 0x%06x" % (n, a_))
    final = collections.Counter(renames.get(n, n) for n in labt[1])
    final.update(inserts.values())
    dup = sorted(n for n, c in final.items() if c > 1)
    return renames, inserts, notes, dup


def apply(tree, renames, inserts, deletes=()):
    files = {p: rd(p) for p in tree_files(tree)}
    backup = dict(files)
    for d in deletes:                               # an unreferenced label line, the name moves on
        hits = [p for p, s in files.items() if p.endswith(".s") and re.search(r"^%s:[ \t]*\n" % re.escape(d), s, re.M)]
        if len(hits) != 1:
            sys.exit("label line %s: found in %d files" % (d, len(hits)))
        files[hits[0]] = re.sub(r"^%s:[ \t]*\n" % re.escape(d), "", files[hits[0]], count=1, flags=re.M)
    if renames:
        tmp = {o: "QQPORTFIX_%d_" % i for i, o in enumerate(sorted(renames))}
        # a quoted string is matched first and kept: "SysSureLngCheck" is the firmware's own text
        rx = re.compile(r'("(?:[^"\\\n]|\\.)*")|(?<![\w.$])(%s)(?![\w$])'
                        % "|".join(re.escape(o) for o in sorted(renames, key=len, reverse=True)))
        for p, s in files.items():
            s2 = rx.sub(lambda m: m.group(1) or tmp[m.group(2)], s)
            for o, t in tmp.items():
                s2 = s2.replace(t, renames[o])
            files[p] = s2
    if inserts:
        import port_maincpu_version as P
        order, _, _ = P.tree_map(tree)
        first = {}
        for e in order:
            if e[0] is not None and e[4] and e[0] not in first:
                txt = e[3].split(";")[0].strip()
                if txt and not re.match(r"^[A-Za-z_.$][\w.$]*:\s*$", txt):
                    first[e[0]] = (e[1], e[2])
        by_file = collections.defaultdict(list)
        for at, name in inserts.items():
            if at not in first:
                sys.exit("no source line starts at 0x%06x for %s" % (at, name))
            rel, line = first[at]
            by_file[os.path.join(ROOT, tree, "maincpu", rel)].append((line, name))
        for p, ins in by_file.items():
            L = files[p].split("\n")
            for line, name in sorted(ins, reverse=True):
                ln = L[line - 1]
                m = re.match(r"^([A-Za-z_.$][\w.$]*:)(\s*)(.*)$", ln)
                L.insert(line - 1, name + ":")
            files[p] = "\n".join(L)
    defined = set()
    for p, s in files.items():
        if p.endswith(".s"):
            defined.update(re.findall(r"^([A-Za-z_][\w$]*):", s, re.M))
    for p, s in files.items():
        if p.endswith(".s"):
            s = re.sub(r"^; port: v\d+'s label (\S+) is not in v\d+ [^\n]*\n(\n)?",
                       lambda m: "" if m.group(1) in defined else m.group(0), s, flags=re.M)
        else:
            s = "".join(ln for ln in s.splitlines(True)
                        if not (ln.split() and ln.split()[0] in defined))
        files[p] = s
    changed = {p: s for p, s in files.items() if s != backup[p]}
    for p, s in changed.items():
        wr(p, s)
    return {p: backup[p] for p in changed}


def evidence(tree):
    probe.PINNED.clear()
    m7 = probe.nom.Map("v7")
    mt = probe.nom.Map(tree)
    lab7, labt = probe.labels("v7"), probe.labels(tree)
    r7, rt = probe.rom("v7"), probe.rom(tree)
    reg = sorted((r["table"], r["table"] + (24 if r["cls"] == 0x1600004 else 4) * (r["count"] + 1))
                 for r in m7.regs if m7.inrom(r["table"]))
    _, rr = probe.check_registry(probe.registry(m7), probe.registry(mt), lab7, labt)
    _, pr = probe.check_ptrtab(r7, rt, lab7, labt, reg)
    suspect = set()
    for r in rr + pr:
        suspect |= set(r["n7"]) | set(r["nt"])
    b7, bt = probe.bodies("v7", set(lab7[1])), probe.bodies(tree, set(labt[1]))
    _, br = probe.check_body(b7, bt, set(lab7[1]), set(labt[1]), suspect, probe.Content(lab7, labt, r7, rt))
    # a label whose T body is, name for name, v7's body of exactly one other label
    owner = collections.defaultdict(list)
    for n, s_ in b7.items():
        if s_:
            owner[s_].append(n)
    bo = []
    for n in sorted(set(b7) & set(bt)):
        st = bt[n]
        if st and st != b7[n] and len(owner.get(st, ())) == 1 and owner[st][0] != n \
                and n not in probe.PINNED and owner[st][0] not in probe.PINNED:
            bo.append(dict(check="body-of", kind="SHIFT", old=n, new=owner[st][0],
                           text="%s has v7's body of %s" % (n, owner[st][0])))
    return dict(lab7=lab7, labt=labt, r7=r7, rt=rt, rows=rr + pr + br + bo)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", required=True, choices=("v6", "v5"))
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--rounds", type=int, default=8)
    a = ap.parse_args()
    ok, err = build_ok(a.tree)
    if not ok:
        sys.exit("%s does not build byte-identical before any edit\n%s" % (a.tree, err))
    total_r = total_i = 0
    dels, ren = hand(a.tree)
    if dels or ren:
        for d in dels:
            print("hand: label line %s deleted" % d)
        for o, n in sorted(ren.items()):
            print("hand: rename %s -> %s" % (o, n))
        if not a.dry_run:
            backup = apply(a.tree, ren, {}, dels)
            ok, err = build_ok(a.tree)
            if not ok:
                for p, s in backup.items():
                    wr(p, s)
                sys.exit("hand edits: not byte-identical; files restored\n%s" % err)
    for rnd in range(1, a.rounds + 1):
        ev = evidence(a.tree)
        renames, inserts, notes, dup = plan(a.tree, ev)
        for n in notes:
            print("round %d: %s" % (rnd, n))
        if dup:
            sys.exit("round %d: these names would be defined twice: %s" % (rnd, " ".join(dup)))
        if not renames and not inserts:
            print("round %d: nothing to do" % rnd)
            break
        for o, n in sorted(renames.items()):
            print("round %d: rename %s -> %s" % (rnd, o, n))
        for at, n in sorted(inserts.items()):
            print("round %d: new label %s at 0x%06x" % (rnd, n, at))
        if a.dry_run:
            break
        backup = apply(a.tree, renames, inserts)
        ok, err = build_ok(a.tree)
        if not ok:
            for p, s in backup.items():
                wr(p, s)
            build_ok(a.tree)
            sys.exit("round %d: not byte-identical; files restored\n%s" % (rnd, err))
        total_r += len(renames)
        total_i += len(inserts)
        print("round %d: byte-identical (%d files)" % (rnd, len(backup)))
    print("%s: %d renames, %d new labels" % (a.tree, total_r, total_i))


if __name__ == "__main__":
    main()
