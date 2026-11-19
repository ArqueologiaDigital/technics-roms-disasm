#!/usr/bin/env python3
"""gen_lane_23w.py: lane_sub's round-23 respelling of the earlier tone-generator writer probes with `__asm`.

QUESTION: do the tone-generator writers (and the other routines with inline nops) match once their inline assembly
is written with the lower-case keyword `__asm("...")`?  Run 2026-11-19-8-sub-r23q-asmkw showed that V4.23 treats
`__asm` as clobbering the scratch registers (a pointer live across it goes to XIZ, pushed, as in the ROM), where
`__ASM` does not; ToneGen_WriteVoice_Reg07 matched (sub_lane_23p2.c).

For each earlier probe file named below, writes scripts/analysis/cc900/corpus/firmware/sub_lane_23w<K><form>.c:
form a = the file with every `__ASM` replaced by `__asm`; form b = also without the `register` storage class
(earlier attempts to move the pointer).  The file's own text is otherwise unchanged.
Run from the repository root: python3 -B notes/cc900-c-subcpu-2026-11-16/helper-generators/gen_lane_23w.py
"""
import os
import re

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
FW = os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware')
SOURCES = ['sub_B_3c', 'sub_C_3c', 'sub_B_3b', 'sub_C_3b', 'sub_A_4c', 'sub_C_7g', 'sub_C_7h']


def main():
    for k, stem in enumerate(SOURCES, 1):
        text = open(os.path.join(FW, stem + '.c'), encoding='latin-1').read()
        a = text.replace('__ASM', '__asm')
        b = re.sub(r'\bregister\s+', '', a)
        for form, body in (('a', a), ('b', b)):
            head = ('/* lane_sub, round 23: %s.c respelled by notes/cc900-c-subcpu-2026-11-16/helper-generators/'
                    'gen_lane_23w.py, form %s: inline assembly as `__asm` (V4.23 then keeps values live across it in '
                    'XIZ, as the ROM does)%s.  The original file follows unchanged otherwise.\n   cc900-options: -Xr */\n\n'
                    % (stem, form, '' if form == 'a' else ', and no `register` storage class'))
            path = os.path.join(FW, 'sub_lane_23w%d%s.c' % (k, form))
            with open(path, 'w', encoding='latin-1') as f:
                f.write(head + body)
            print(path)


if __name__ == '__main__':
    main()
