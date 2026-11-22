#!/usr/bin/env python3
"""Step Z3 of the feedback plan: the `djnz` pool.

QUESTION ANSWERED: the lanes' screens (notes/cc900-phase6-2026-11-16/xr_screen.py, notes/cc900-c-subcpu-2026-11-16/
sub_screen.py, notes/cc900-c-hdae5000-2026-11-16/hd_screen.py) reject any routine with a `djnz` as hand-written, but
V4.23 writes `djnz` for counted loops (rules.md, djnz-loop: kn5000 state V4.23).  Which hand-source routines hold a
`djnz`, and which of them look compiled once `djnz` no longer counts against them?

For each tree (main CPU v10, sub-CPU v1.42, HD-AE5000 v2.06i) every `djnz` line of the hand source is assigned to its
routine (v10: the routines of notes/cc900-phase6-2026-11-16/modules_v10.tsv; the others: the nearest label before it
that is not local, i.e. not `.L...`).  Per routine:
  hand    the screens' other hand marks: ei / di, ldc, swi, reti, link / unlk, xor r,r, halt, and (main CPU and
          HD-AE5000 only) bank-register forms (_werp / _berp / ldf / incf / decf)
  frame   a cc900 frame in the first 6 instructions: push xiz / pushw iz, or lda xsp,(xsp-N) / dec N,xsp
  spill   a parameter register stored to the frame in the first 8 instructions
  calls   call / calr count;  insns  instruction count
Class: `compiled-looking` = hand 0 and (frame or spill); `no frame` = hand 0, neither; `hand` = a hand mark.
Routines already built from C are not in the hand source and so never listed.

Usage, from technics-roms-disasm's root:
    python3 -B notes/cc900-feedback-plan-2026-11-22/z3_pool.py [--tsv OUT.tsv]
Prints Markdown (summary and the compiled-looking list).
"""
import collections
import glob
import os
import re
import sys

TREES = [('v10', 'v10/maincpu', True), ('v142', 'v142/subcpu', False), ('hdae5000', 'hdae5000', True)]
MODULES_V10 = 'notes/cc900-phase6-2026-11-16/modules_v10.tsv'
LABEL = re.compile(r'^([A-Za-z_.$][\w.$]*):')
DJNZ = re.compile(r'^djnz\w*\b', re.I)
HAND = [r'^(ei|di|ldc|swi|reti|link|unlk|halt)\b', r'^xor\s+(\w+)\s*,\s*\1\s*$']
BANK = r'_werp|_berp|^ldf\b|^incf\b|^decf\b'
FRAME = re.compile(r'^(push\s+xiz|pushw\s+iz|lda\s+xsp\s*,\s*\(xsp\s*-|dec\s+\d+\s*,\s*xsp)\b', re.I)
SPILL = re.compile(r'^ld\s+\(xsp\s*\+\s*\d+(:\d+)?\)\s*,\s*(xwa|xbc|xde|wa|bc|de|a|c|e)\s*$', re.I)


def instructions(path):
    """[(label or None, instruction text)] of a .s file, comments and directives dropped (labels kept)"""
    out = []
    for raw in open(path, 'rb').read().decode('latin-1').splitlines():
        code = raw.split(';', 1)[0].rstrip()
        m = LABEL.match(code)
        if m:
            out.append((m.group(1), None))
            code = code[len(m.group(0)):]
        t = code.strip()
        if t and not t.startswith('.'):
            out.append((None, re.sub(r'\s+', ' ', t)))
    return out


def main():
    a = sys.argv[1:]
    v10_routines = {l.split('\t')[1] for l in open(MODULES_V10).read().splitlines()[1:] if l.count('\t') == 3}
    pool = []
    for key, tree, bank_is_hand in TREES:
        files = sorted(set(glob.glob(os.path.join(tree, '**', '*.s'), recursive=True)))
        for path in files:
            items = instructions(path)
            cur, body = None, []
            routines = []
            for lab, ins in items:
                if lab is not None:
                    starts = lab in v10_routines if key == 'v10' else not lab.startswith('.')
                    if starts:
                        if cur:
                            routines.append((cur, body))
                        cur, body = lab, []
                    continue
                if cur:
                    body.append(ins)
            if cur:
                routines.append((cur, body))
            for name, body in routines:
                sites = sum(1 for i in body if DJNZ.match(i))
                if not sites:
                    continue
                marks = HAND + ([BANK] if bank_is_hand else [])
                hand = sum(1 for i in body for m in marks if re.search(m, i, re.I))
                frame = any(FRAME.match(i) for i in body[:6])
                spill = any(SPILL.match(i) for i in body[:8])
                cls = 'hand' if hand else ('compiled-looking' if frame or spill else 'no frame')
                pool.append(dict(image=key, routine=name, file=os.path.relpath(path), djnz=sites, hand=hand,
                                 frame=int(frame), spill=int(spill),
                                 calls=sum(1 for i in body if re.match(r'^cal[lr]\b', i, re.I)), insns=len(body),
                                 cls=cls))
    cols = ['image', 'routine', 'file', 'djnz', 'hand', 'frame', 'spill', 'calls', 'insns', 'cls']
    if '--tsv' in a:
        with open(a[a.index('--tsv') + 1], 'w') as f:
            f.write('\t'.join(cols) + '\n')
            for p in pool:
                f.write('\t'.join(str(p[c]) for c in cols) + '\n')

    def table(head, rows):
        w = [max(len(str(x)) for x in c) for c in zip(head, *rows)] if rows else [len(h) for h in head]
        out = ['| ' + ' | '.join(str(h).ljust(n) for h, n in zip(head, w)) + ' |',
               '|' + '|'.join('-' * (n + 2) for n in w) + '|']
        out += ['| ' + ' | '.join(str(x).ljust(n) for x, n in zip(r, w)) + ' |' for r in rows]
        return '\n'.join(out)

    print('## Z3: routines of the hand source holding a `djnz`\n')
    s = collections.defaultdict(lambda: [0, 0])
    for p in pool:
        s[(p['image'], p['cls'])][0] += 1
        s[(p['image'], p['cls'])][1] += p['djnz']
    print(table(('image', 'class', 'routines', 'djnz sites'), [(k[0], k[1], v[0], v[1]) for k, v in sorted(s.items())]))
    print('\n## The compiled-looking routines (no other hand mark, a cc900 frame or a parameter spill)\n')
    cl = sorted((p for p in pool if p['cls'] == 'compiled-looking'), key=lambda p: (p['image'], -p['insns']))
    print(table(('image', 'routine', 'file', 'djnz', 'frame', 'spill', 'calls', 'insns'),
                [(p['image'], p['routine'], p['file'], p['djnz'], p['frame'], p['spill'], p['calls'], p['insns'])
                 for p in cl]))


if __name__ == '__main__':
    main()
