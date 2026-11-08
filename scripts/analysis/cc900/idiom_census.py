#!/usr/bin/env python3
"""Idiom census: how often does each candidate rule's instruction pattern occur in the firmware's code?

usage: python3 -I -B idiom_census.py [TREE ...]        (default: v10/maincpu v142/subcpu hdae5000)
Run from the repository root.  For each candidate rule of the cc900-compat rule list
(notes/cc900-compat-plan-2026-11-08/), each of its two behaviours has a detector: a pattern over consecutive
instruction lines of our LLVM-syntax sources (comments, labels and directives skipped).  A behaviour at zero
occurrences while the other has many decides the rule for that tree (PLAN.md section 2, step 3).  The trees mix
compiled C with hand-written assembly and Toshiba's runtime, so a count is evidence, not proof: the examples printed
for each detector show where to look.

Reads every .s file with read_bytes() (the trees hold non-UTF-8 bytes; a recursive grep skips them).
"""
import re, sys, glob

def lines(path):
    out = []
    for i, raw in enumerate(open(path, 'rb').read().split(b'\n')):
        s = re.sub(r'\s*;.*', '', raw.decode('latin-1')).strip()
        if not s or s.endswith(':') or s.startswith('.'): continue
        out.append((i + 1, re.sub(r'\s+', ' ', s.replace('\t', ' ')).lower()))
    return out

SLOT = r'\((xsp ?\+ ?(?:0x)?[0-9a-f]+(?::8)?)\)'

def store_reload(code, k):
    m = re.match(r'ld ' + SLOT + r' ?, ?(\w+)$', code[k][1])
    if not m or k + 1 >= len(code): return False
    m2 = re.match(r'ld (\w+) ?, ?' + SLOT + '$', code[k + 1][1])
    return bool(m2) and m2.group(1) == m.group(2) and m2.group(2).replace(' ', '') == m.group(1).replace(' ', '')

def djnz(code, k):
    return re.match(r'djnz(8|16)? ', code[k][1]) is not None

def sub1_jrne(code, k):
    m = re.match(r'sub (bc|wa|de|hl|ix|iy|iz|b|c|a) ?, ?1$', code[k][1])
    return bool(m) and k + 1 < len(code) and re.match(r'jrl? (ne|nz) ?,', code[k + 1][1]) is not None

RULES = [
    ('reload-after-store', 'store then reload of the same (xsp+d) slot', store_reload),
    ('djnz-loop', '`djnz` (V4.23 keeps it)', djnz),
    ('djnz-loop', '`sub r,1` + `jr ne` (2003 replaces djnz with it)', sub1_jrne),
]

def main():
    trees = sys.argv[1:] or ['v10/maincpu', 'v142/subcpu', 'hdae5000']
    print('| tree | rule | detector | count | examples |')
    print('|---|---|---|---|---|')
    for t in trees:
        files = sorted(glob.glob(t + '/**/*.s', recursive=True))
        code = {f: lines(f) for f in files}
        for rule, what, det in RULES:
            hits = [(f, c[k][0]) for f, c in code.items() for k in range(len(c)) if det(c, k)]
            ex = ', '.join('`%s:%d`' % h for h in hits[:3])
            print('| %s | %s | %s | %d | %s |' % (t, rule, what, len(hits), ex))

main()
