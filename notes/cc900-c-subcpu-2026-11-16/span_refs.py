#!/usr/bin/env python3
"""Can a switch that spans several labels be written as ONE C function?

QUESTION ANSWERED: for a routine whose case bodies sit under labels of their own, which of those inner labels
does anything OUTSIDE the routine reference (a call, a jump, an address taken, a table entry)?  An inner label
nothing outside names is a case body: the routine is one C function from its first label to the end of its last
case body, and the splice keeps the inner labels as `.set` offsets.  An inner label referenced from outside is a
real separate entry point, and the split stays there.

The span is the routine's label line up to the line before END (the next routine's label).  Every `.s` file of
the tree (v142/subcpu) and its C (cc900/*.c) is read as bytes; a reference is the label as a whole word on a
non-comment line outside the span.  Prints, per inner label, OUTSIDE (with file:line of each) or inner-only.

    python3 -B notes/cc900-c-subcpu-2026-11-16/span_refs.py FILE.s START END [TABLE ...]      (repository root)
    e.g.  span_refs.py v142/subcpu/core/07_voice_ctrlchange.s Voice_CtrlChange Voice_ChanPressure \\
              Voice_CC_Mode_CaseOffsets

A TABLE is the switch's own case-offset table (its cc900-data object, which V4.23 generates with the function):
references from its lines (from its label to the next label) do not count as outside.
"""
import glob, os, re, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
TREE = 'v142/subcpu'


def code_part(line):
    return line.split(b';', 1)[0]


def main():
    a = sys.argv[1:]
    if len(a) < 3:
        sys.exit(__doc__)
    path, start, end, tables = a[0], a[1], a[2], [t.encode() for t in a[3:]]
    lines = open(os.path.join(REPO, path), 'rb').read().split(b'\n')
    lab = re.compile(rb'^([A-Za-z_.$][\w.$]*):')
    s = next(i for i, l in enumerate(lines) if l.startswith(start.encode() + b':'))
    e = next(i for i, l in enumerate(lines) if i > s and l.startswith(end.encode() + b':'))
    inner = []
    for l in lines[s + 1:e]:
        m = lab.match(l)
        if m and not m.group(1).startswith(b'.'):
            inner.append(m.group(1))
    files = sorted(glob.glob(os.path.join(REPO, TREE, '**', '*.s'), recursive=True) +
                   glob.glob(os.path.join(REPO, TREE, 'cc900', '*.c')))
    hits = {n: [] for n in inner}
    for f in files:
        rel = os.path.relpath(f, REPO)
        flines = open(f, 'rb').read().split(b'\n')
        in_table = False
        for i, l in enumerate(flines):
            if rel == path and s <= i < e:
                continue
            m = lab.match(l)
            if m:
                in_table = m.group(1) in tables
            if in_table:
                continue
            c = code_part(l) if f.endswith('.s') else l
            for n in inner:
                if re.search(rb'(?<![\w.$])' + re.escape(n) + rb'(?![\w$])', c):
                    if c.startswith(n + b':'):
                        continue
                    hits[n].append('%s:%d' % (rel, i + 1))
    print('%s .. %s: %d lines, %d inner labels' % (start, end, e - s, len(inner)))
    for n in inner:
        h = hits[n]
        print('  %-40s %s' % (n.decode(), ('OUTSIDE ' + ' '.join(h[:6]) + (' ...' if len(h) > 6 else '')) if h
                              else 'inner-only'))


if __name__ == '__main__':
    main()
