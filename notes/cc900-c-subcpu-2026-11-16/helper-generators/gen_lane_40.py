#!/usr/bin/env python3
"""gen_lane_40.py: lane_sub's round-40 forms of Voice_SetVelocity, from helper AQ's sub_AQ_36a.c.

QUESTION: V4.23 folds the +10 of `buf[(int)i + 10]` (a local 14-byte array) into the frame address (lda xbc,xsp+12),
where the ROM widens i, adds 10 in WA and keeps the base at xsp+2 (runs 2026-11-19-69 .. -74; a unary plus, a comma,
pointer arithmetic and a struct member did not stop the fold).  These forms take the index out of the subscript:
  a: the index through an int local, `k = (int)i + 10; ... buf[k]` (k not live across calls: WA);
  b: the constant through an int local (idiom (b)), `ten = 10; ... buf[(int)i + ten]`;
  c: the base through a pointer local, `p = &buf[0]; ... p[(int)i + 10]` (a pointer cannot be folded into the frame).
Writes scripts/analysis/cc900/corpus/firmware/sub_lane_40{a,b,c}.c.
Run from the repository root: python3 -B notes/cc900-c-subcpu-2026-11-16/helper-generators/gen_lane_40.py
"""
import os, re

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
FW = os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware')
IDX = 'buf[(int)i + 10]'


def form(text, which):
    if which == 'a':
        text = text.replace('    unsigned char buf[14];', '    unsigned char buf[14];\n    int k;', 1)
        # `ch = buf[...]` statements: compute the index first; inside conditions use (k = ..., buf[k])
        text = re.sub(r'(\n(\s*))ch = buf\[\(int\)i \+ 10\];', r'\1k = (int)i + 10;\1ch = buf[k];', text)
        text = text.replace(IDX, 'buf[(k = (int)i + 10)]')
    elif which == 'b':
        text = text.replace('    unsigned char buf[14];\n\n', '    unsigned char buf[14];\n    int ten;\n\n    ten = 10;\n', 1)
        text = text.replace(IDX, 'buf[(int)i + ten]')
    else:
        text = text.replace('    unsigned char buf[14];\n\n',
                            '    unsigned char buf[14];\n    unsigned char *p;\n\n    p = &buf[0];\n', 1)
        text = text.replace(IDX, 'p[(int)i + 10]')
    return text


def main():
    src = open(os.path.join(FW, 'sub_AQ_36a.c'), encoding='latin-1').read()
    for w in 'abc':
        t = form(src, w)
        head = '/* lane_sub round 40, form %s of Voice_SetVelocity (gen_lane_40.py; see its docstring), from sub_AQ_36a.c.\n   cc900-options: -Xr */\n' % w
        with open(os.path.join(FW, 'sub_lane_40%s.c' % w), 'w', encoding='latin-1') as f:
            f.write(head + t)
        print(os.path.join(FW, 'sub_lane_40%s.c' % w))


if __name__ == '__main__':
    main()
