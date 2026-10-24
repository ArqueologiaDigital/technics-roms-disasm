#!/usr/bin/env python3
"""Which comments of a ported HD-AE5000 tree still quote a v2.06i number?

QUESTION ANSWERED
    scripts/tools/port_hdae5000_version.py rewrites the CODE of a source line (a
    literal, a constant, a label) and keeps its comment.  When the comment quotes
    the number the code used to hold -- `ld xbc, 0xf4ce ; Count = 62,762 bytes`,
    `lda xbc, (0x23a055:24) ; XBC = 0x23A0D2` -- the comment is now wrong for the
    version.  This pairs every line of the version tree with its v2.06i twin (a
    line-level diff of each file; a changed line is paired when its replace block
    has as many lines on both sides), takes the numbers that left the code part,
    and lists the paired lines whose comment still quotes one of them (as hex,
    any case or width, or as decimal with or without thousands commas).

    With --fix, a quoted number that is hex is replaced by the new value in the
    same width and case; a decimal one by the new value in decimal (with commas if
    the old one had them).  A comment where the old and new numbers cannot be paired
    one to one is only listed.

RUN
    python3 scripts/analysis/hdae5000_version_stale_comments.py v2_01i [--fix]
"""
import difflib
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NUM = re.compile(rb'(?<![\w.])(0x[0-9a-fA-F]+|\d[\d,]*\d|\d)(?![\w])')


def split(line):
    q = False
    for i, c in enumerate(line):
        if c == 0x22:
            q = not q
        elif c == 0x3B and not q:
            return line[:i], line[i:]
    return line, b""


def val(t):
    return int(t, 16) if t.lower().startswith(b"0x") else int(t.replace(b",", b""), 10)


def nums(code):
    return [val(m.group(1)) for m in NUM.finditer(code)]


def render(tok, v):
    if tok.lower().startswith(b"0x"):
        digits = len(tok) - 2
        s = b"%0*x" % (digits, v)
        return b"0x" + (s.upper() if tok[2:].upper() == tok[2:] and any(c in b"ABCDEF" for c in tok[2:]) else s)
    if b"," in tok:
        return ("{:,}".format(v)).encode()
    return str(v).encode()


def main():
    ver = sys.argv[1] if len(sys.argv) > 1 else "v2_01i"
    fix = "--fix" in sys.argv
    tree = os.path.join(ROOT, "hdae5000_" + ver)
    total = fixed = 0
    for fn in sorted(os.listdir(tree)):
        if not fn.endswith(".s"):
            continue
        wf = os.path.join(ROOT, "hdae5000", "hd-ae5000_v2_06i.s" if fn.startswith("hd-ae5000_") else fn)
        a = open(wf, "rb").read().split(b"\n")
        b = open(os.path.join(tree, fn), "rb").read().split(b"\n")
        sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
        for op, i1, i2, j1, j2 in sm.get_opcodes():
            if op != "replace" or i2 - i1 != j2 - j1:
                continue
            for i, j in zip(range(i1, i2), range(j1, j2)):
                ca, ka = split(a[i])
                cb, kb = split(b[j])
                if not kb or kb != ka:
                    continue
                na, nb = nums(ca), nums(cb)
                gone = [v for v in na if v not in nb]
                if not gone:
                    continue
                quoted = [m for m in NUM.finditer(kb) if val(m.group(1)) in gone]
                if not quoted:
                    continue
                total += 1
                pairs = {}
                if len(na) == len(nb):
                    for x, y in zip(na, nb):
                        if x != y:
                            pairs.setdefault(x, set()).add(y)
                ok = all(len(pairs.get(val(m.group(1)), ())) == 1 for m in quoted)
                if fix and ok:
                    new = kb
                    for m in reversed(quoted):
                        v = val(m.group(1))
                        new = new[:m.start()] + render(m.group(1), next(iter(pairs[v]))) + new[m.end():]
                    b[j] = cb + new
                    fixed += 1
                else:
                    print("%s:%d  %s" % (fn, j + 1, b[j].decode("latin-1").strip()))
        if fix:
            open(os.path.join(tree, fn), "wb").write(b"\n".join(b))
    print("%d comments quote a number their code no longer has; %d rewritten" % (total, fixed))


if __name__ == "__main__":
    main()
