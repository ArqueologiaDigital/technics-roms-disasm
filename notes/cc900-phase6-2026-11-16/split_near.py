#!/usr/bin/env python3
"""Give every declarator of an `extern ... __near a, b, c;` line its own declaration.

QUESTION ANSWERED / WHY: V4.23 applies `__near` / `__tiny` to the FIRST declarator of a declaration only:
`extern unsigned int __near ram_28c3, SEQ_COUNT_IN;` declares ram_28c3 medium (16-bit) but SEQ_COUNT_IN large
(24-bit) (run 2026-11-16-30-p6-r1, the staged SeqAcc_UpdateEndPosition).  This rewrites such lines in place as
`extern unsigned int __near ram_28c3;` / `extern unsigned int __near SEQ_COUNT_IN;`.  Lines whose declarators hold
`*` or `(` are left alone and listed, since where the qualifier belongs there is a choice to make by hand.

usage: python3 notes/cc900-phase6-2026-11-16/split_near.py FILE.c ...
"""
import re, sys

LINE = re.compile(r'^(\s*extern\s+[\w\s]*?\b(?:__near|__tiny)\b\s+)([^;]+);(\s*(?:/\*.*\*/)?\s*)$')


def main():
    for p in sys.argv[1:]:
        src = open(p, encoding='latin-1').read().split('\n')
        out, n = [], 0
        for l in src:
            m = LINE.match(l)
            if not m or ',' not in m.group(2):
                out.append(l); continue
            decls = [d.strip() for d in m.group(2).split(',')]
            if any('*' in d or '(' in d for d in decls):
                print('%s: left alone: %s' % (p, l.strip())); out.append(l); continue
            out += ['%s%s;' % (m.group(1), d) for d in decls]
            if m.group(3).strip():
                out[-1] += m.group(3)
            n += 1
        open(p, 'w', encoding='latin-1').write('\n'.join(out))
        print('%s: %d declarations split' % (p, n))


if __name__ == '__main__':
    main()
