#!/usr/bin/env python3
"""How does the firmware enter its loops?  An idiom census for the candidate kn5000 loop-inversion rule.

QUESTION ANSWERED: V4.23 at -O3 -XS -Xr enters a `while` / `for` loop by jumping to the test at the bottom
(run 2026-11-16-9-p6-m3: every form tried).  TrimAndPadSmfFilename's padding loop instead tests the condition
before entering and again at the bottom ("inverted"), while its first loop, whose condition is compound, uses the
jump.  How many loops of a tree have each shape, and does the shape follow the condition's complexity?

A loop is a backward conditional branch (`jr cc` / `jrl cc` / `djnz` to a label earlier in the same file).  Its top
is that label; its bottom test is the branch with the instructions just before it back to the previous label or
branch.  The entry is read from the instruction before the top:
    jump-to-test   an unconditional `jr` / `jrl` forward to a label between the top and the bottom branch
    inverted       a conditional `jr` / `jrl` forward to the first label after the bottom branch, i.e. a test that
                   skips the loop, whose compare repeats the bottom test's compare ("same test"), or not ("other test")
    djnz           the bottom branch is `djnz` (counted loops: no entry test)
    fall-in        anything else (a do-while, or a loop entered from code we cannot classify)
The bottom test is "simple" when one compare and one branch decide it, "compound" when the block from the
jump-to-test target to the bottom branch holds more than one conditional branch.  This reads the source, so it
counts hand assembly too: a census of shapes, not of compiler output.

usage: python3 notes/cc900-phase6-2026-11-16/loop_shapes.py [TREE] [--list SHAPE]
    TREE defaults to v10/maincpu.  --list prints file:line and top label of every loop of that shape.
"""
import collections, os, re, sys

LABEL = re.compile(r'^([A-Za-z_.$][\w.$]*):\s*(.*)$')
COND = re.compile(r'^(jr|jrl)\s+(\w+)\s*,\s*([A-Za-z_.$][\w.$]*)\s*$')
UNCOND = re.compile(r'^(jr|jrl)\s+(?:t\s*,\s*)?([A-Za-z_.$][\w.$]*)\s*$')
DJNZ = re.compile(r'^djnz\w*\s+\w+\s*,\s*([A-Za-z_.$][\w.$]*)\s*$')


def items(path):
    """[(line number, labels before this instruction, instruction text)], comments stripped"""
    out, pend = [], []
    for n, raw in enumerate(open(path, encoding='latin-1').read().split('\n'), 1):
        c = raw.split(';')[0].strip()
        while True:
            m = LABEL.match(c)
            if not m:
                break
            pend.append(m.group(1)); c = m.group(2).strip()
        if c and not c.startswith('.'):
            out.append((n, pend, ' '.join(c.split()).lower())); pend = []
        elif c.startswith('.'):
            pend = []
    return out


def census(tree):
    shapes = collections.Counter(); where = collections.defaultdict(list)
    for dp, dn, fn in os.walk(tree):
        dn[:] = sorted(d for d in dn if d != 'generated')
        for f in sorted(fn):
            if not f.endswith('.s'):
                continue
            p = os.path.join(dp, f)
            it = items(p)
            at = {}
            for k, (_, labs, _) in enumerate(it):
                for l in labs:
                    at[l.lower()] = k
            for k, (n, _, ins) in enumerate(it):
                m = COND.match(ins); d = DJNZ.match(ins)
                tgt = (m.group(3) if m and m.group(2) != 't' else d.group(1) if d else None)
                if tgt is None or tgt.lower() not in at or at[tgt.lower()] > k:
                    continue
                top = at[tgt.lower()]
                if d:
                    shape = 'djnz'
                else:
                    shape = 'fall-in'
                    prev = it[top - 1][2] if top > 0 else ''
                    u = UNCOND.match(prev); c = COND.match(prev)
                    if u and u.group(2).lower() in at and top <= at[u.group(2).lower()] <= k:
                        conds = sum(1 for _, _, x in it[at[u.group(2).lower()]:k + 1] if COND.match(x) and
                                    COND.match(x).group(2) != 't')
                        shape = 'jump-to-test, %s' % ('simple' if conds == 1 else 'compound')
                    elif c and c.group(2) != 't' and c.group(3).lower() in at and at[c.group(3).lower()] == k + 1:
                        same = top >= 2 and k >= 1 and it[top - 2][2] == it[k - 1][2]
                        shape = 'inverted, %s' % ('same test' if same else 'other test')
                shapes[shape] += 1
                where[shape].append('%s:%d  %s' % (os.path.relpath(p, tree), n, tgt))
    return shapes, where


def main():
    a = sys.argv[1:]
    tree = next((x for x in a if not x.startswith('--') and (a.index(x) == 0 or a[a.index(x) - 1] != '--list')),
                'v10/maincpu')
    shapes, where = census(tree)
    if '--list' in a:
        for w in where[a[a.index('--list') + 1]]:
            print(w)
        return
    rows = sorted(shapes.items(), key=lambda kv: -kv[1])
    w = max(len(s) for s, _ in rows + [('shape', 0)])
    print('| %s | loops |' % 'shape'.ljust(w))
    print('|%s|-------|' % ('-' * (w + 2)))
    for s, n in rows:
        print('| %s | %5d |' % (s.ljust(w), n))
    print('| %s | %5d |' % ('total'.ljust(w), sum(shapes.values())))


if __name__ == '__main__':
    main()
