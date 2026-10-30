#!/usr/bin/env python3
"""Does every label of a ported HD-AE5000 tree still name what it names in v2.06i?

QUESTION ANSWERED
    A version tree such as hdae5000_v2_01i/ was ported from hdae5000/ (v2.06i)
    by scripts/tools/port_hdae5000_version.py.  Byte-exactness proves every
    label the code or data REFERENCES sits where the ROM needs it.  It proves
    nothing about a label nothing references: the porting tool keeps the labels
    of code the target lacks, and when it aligns a changed routine it can leave
    a label one instruction off.  This lists, for the version tree:

      moved     a label both trees have whose first instructions differ in
                shape (mnemonic and registers, numbers masked) between the two
                builds -- it may name different code now;
      pile      two or more labels on one address where v2.06i has them on
                different addresses (labels of deleted code collected in front
                of the next surviving instruction);
      orphan    labels marked `PORT-ORPHAN` by the porting tool;
      new       labels only the version tree has (named by the tool or by hand);
    and for each whether anything references it (a referenced label is pinned
    by the bytes; an unreferenced one is only pinned by this review).

    Data labels are compared by their first 8 bytes instead of instructions.

INPUTS
    The two source trees, assembled here (scripts/tools/port_hdae5000_version.py's
    marker build, with --save-temp-labels so that .L labels are compared too).

RUN
    python3 scripts/analysis/hdae5000_version_label_check.py v2_01i [--all] [--base v2_06i]
    (--base: the tree compared with, default v2.06i; v1.15i was ported from v2_01i and
    v1.10i from v1_15i.  The GUI's macro-made labels are left out.)
    Prints a summary, then the moved / pile / orphan rows (--all: also the
    unreferenced new labels).  Exit status 0 always: this is a review list.
"""
import collections
import glob
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BIN = os.environ.get("LLVM_BIN", os.path.expanduser("~/compartilhado/llvm-project/build/bin"))
UNIDASM = os.environ.get("UNIDASM", os.path.expanduser("~/compartilhado/tools/unidasm"))
SCRATCH = os.environ.get("TMPDIR") or os.path.expanduser("~/compartilhado/tmp")
BASE = 0x280000
CODE_END = 0x29b000
NUM = re.compile(r'0x[0-9a-f]+|(?<![\w])\d+(?![\w])')
IDENT = re.compile(rb'(?<![\w.@])(\.L[A-Za-z_]\w*|[A-Za-z_]\w*)')
LABEL = re.compile(rb'^(\.L[A-Za-z_]\w*|[A-Za-z_]\w*):')


def syms(elf):
    out = subprocess.run([BIN + "/llvm-nm", "--defined-only", elf], capture_output=True,
                         text=True, check=True).stdout
    d = {}
    for l in out.split("\n"):
        p = l.split()
        if len(p) == 3 and p[1] in "tT":
            d[p[2]] = int(p[0], 16)
    return d


CALLS = re.compile(r'^(call|calr|jp|jr|jrl|djnz)\b')


def decode(img, names=None):
    """{address: (length, shape)}.  A shape masks numbers, except that the target of a
    call or jump is replaced by the name a routine-level label gives it (names: address
    -> name, local .L / _Skip / _Join-style names left out), so a label that slid onto
    the next step of a chain of look-alike steps still differs."""
    p = os.path.join(SCRATCH, "hdae5000_label_check_%d.bin" % os.getpid())
    open(p, "wb").write(img)
    out = subprocess.run([UNIDASM, p, "-arch", "tlcs900", "-basepc", "%x" % BASE],
                         capture_output=True, text=True).stdout
    os.remove(p)
    ins = {}
    for l in out.split("\n"):
        m = re.match(r'^([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*(.*)$', l)
        if m:
            a = int(m.group(1), 16)
            t = m.group(3).strip().lower()
            if names and CALLS.match(t):
                t = re.sub(r'0x([0-9a-f]{6})\b',
                           lambda mm: names.get(int(mm.group(1), 16), mm.group(0)), t)
            ins[a] = (len(m.group(2).split()), NUM.sub("N", t))
    return ins


def routine_names(sym):
    keep = {}
    for n, a in sym.items():
        if n.startswith(".L") or re.search(r'_(Skip|Join|Loop|Next|Done|Default)\d*$', n):
            continue
        keep.setdefault(a, n)
    return keep


def shapes(ins, img, a, n=3, code_end=CODE_END):
    if a >= code_end:
        return img[a - BASE:a - BASE + 8].hex()
    out = []
    while len(out) < n and a in ins:
        ln, sh = ins[a]
        out.append(sh)
        a += ln
    return " | ".join(out) if out else "(no instruction)"


def references(tree_dirs):
    refs = collections.Counter()
    marked = set()
    for d in tree_dirs:
        for f in glob.glob(os.path.join(d, "*.s")):
            for ln in open(f, "rb").read().split(b"\n"):
                m = LABEL.match(ln)
                code = ln.split(b";")[0] if b'"' not in ln else ln
                if m:
                    if b"PORT-ORPHAN" in ln:
                        marked.add(m.group(1).decode())
                    code = code[m.end():]
                for t in IDENT.findall(code):
                    refs[t.decode()] += 1
    return refs, marked


def main():
    ver = sys.argv[1] if len(sys.argv) > 1 else "v2_01i"
    sys.path.insert(0, os.path.join(ROOT, "scripts", "tools"))
    import port_hdae5000_version as P0
    base = P0.base_of(sys.argv)
    btree, bmain = P0.base_tree(base)
    tree = os.path.join(ROOT, "hdae5000_" + ver)
    # both trees assembled with --save-temp-labels (the porting tool's marker build),
    # so the .L local labels are checked too
    sys.path.insert(0, os.path.join(ROOT, "scripts", "tools"))
    import port_hdae5000_version as P
    ba = P.Build(btree, bmain, P.incs_of(base),
                 os.path.join(P.SCRATCH, "port_hdae5000_labelcheck_a"))
    bb = P.Build(tree, "hd-ae5000_%s.s" % ver, P.incs_of(ver),
                 os.path.join(P.SCRATCH, "port_hdae5000_labelcheck_b"))
    assert ba.ok and bb.ok, (ba.stderr[-500:], bb.stderr[-500:])
    ia, ib = ba.img, bb.img
    # the GUI's labels (HdaeUi*, _ui_*) are made by the class macros from the tree that
    # scripts/converters/hdae5000_ui_tree.py generates and checks against the ROM: not
    # reviewed here
    gui = ("__PM_", "_ui_", "HdaeUi", ".L_ui")
    sa = {n: a for a, n in ba.syms if not n.startswith(gui)}
    sb = {n: a for a, n in bb.syms if not n.startswith(gui)}
    da, db = decode(ia, routine_names(sa)), decode(ib, routine_names(sb))
    # the code ends where the registered-object name pool begins, in each version
    ea, eb = sa.get("HDAE5000_Str_End_ObjNames", CODE_END), sb.get("HDAE5000_Str_End_ObjNames", CODE_END)
    refs, marked = references([tree])
    at_a = collections.defaultdict(set)
    at_b = collections.defaultdict(set)
    for n, a in sa.items():
        at_a[a].add(n)
    for n, a in sb.items():
        at_b[a].add(n)
    rows = collections.defaultdict(list)
    for n, b in sorted(sb.items(), key=lambda kv: kv[1]):
        r = refs.get(n, 0)
        if n in marked:
            rows["orphan"].append((b, n, r, ""))
        if n not in sa:
            rows["new"].append((b, n, r, shapes(db, ib, b, code_end=eb)))
            continue
        a = sa[n]
        x, y = shapes(da, ia, a, code_end=ea), shapes(db, ib, b, code_end=eb)
        if x != y:
            rows["moved"].append((b, n, r, "v2.06i: %s\n%s      %s: %s" % (x, " " * 8, ver, y)))
        mates_b = at_b[b] & set(sa)
        if len(mates_b) > 1 and len({sa[m] for m in mates_b}) > 1:
            rows["pile"].append((b, n, r, ""))
    # A new label may stand where a v2.06i label of the same routine stood: the tool
    # names a branch target it cannot map.  Suggest the old name when the old label is
    # missing or unreferenced here, sits within 0x400 bytes, and its v2.06i code starts
    # with the same three instruction shapes as the new label's.
    for b, n, r, info in rows["new"]:
        if b >= eb:
            continue
        here = shapes(db, ib, b, code_end=eb)
        best = None
        for m, a in sa.items():
            if m in sb and refs.get(m, 0):
                continue
            if m.startswith("__") or abs(sb.get(m, a) - b) > 0x400 and abs(a - b) > 0x1000:
                continue
            if shapes(da, ia, a, code_end=ea) == here and (best is None or abs(a - b) < abs(sa[best] - b)):
                best = m
        if best:
            rows["suggest"].append((b, n, r, "-> %s (v2.06i 0x%06x%s)" % (
                best, sa[best], ", here unreferenced at 0x%06x" % sb[best] if best in sb else ", gone")))
    print("%s: %d labels (%d also in v2.06i); moved %d, in piles %d, orphan-marked %d, new %d, "
          "rename suggestions %d"
          % (ver, len(sb), len(set(sb) & set(sa)), len(rows["moved"]), len(rows["pile"]),
             len(rows["orphan"]), len(rows["new"]), len(rows["suggest"])))
    for b, n, r, info in rows["suggest"]:
        print("  suggest %06x %-48s %s" % (b, n, info))
    for kind in ("moved", "pile", "orphan") + (("new",) if "--all" in sys.argv else ()):
        print("\n== %s" % kind)
        for b, n, r, info in rows[kind]:
            if kind == "new" and r:
                continue
            print("  %06x %-52s refs %-3d %s" % (b, n, r, info))


if __name__ == "__main__":
    main()
