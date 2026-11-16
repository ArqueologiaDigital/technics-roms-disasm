#!/usr/bin/env python3
"""Write round 14's idiom probes: the class (b) follow-up and the returned-pointer copy (XHL -> XDE).

QUESTION ANSWERED: which C spelling of the DSP_TableWalk_Search call makes V4.23 produce
  (rb) DSP_AlgoDescriptor_Emit's order: the stack parameter tbl loaded into XHL, then `ld bc,0x78`, then &st pushed;
       round 13's local `k = 0x78` fixed this in DSP_TuneOffset but got a register of its own (DE) here;
  (ra) DSP_TuneOffset's `ld xde,xhl` / `ld a,(xde)` after the call: the returned pointer kept in a register local.
Each file holds one function in one spelling; the rest of the function is round 13's sub_E_ib06.c.
Round 15 adds ra11..14 (the parameter tbl reused for the result: tbl's register is XDE) and rb15..18 (the stack
offsets say the ROM's third argument of the call is the LAST parameter, at +14, not type at +18: V4.23 pushes
stack arguments left to right, so the last parameter has the lowest offset).

    python3 -B notes/cc900-c-subcpu-2026-11-16/gen_r14_probes.py     (repository root; writes
    scripts/analysis/cc900/corpus/firmware/sub_F_ra*.c and sub_F_rb*.c)
"""
import os

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..', '..', 'scripts', 'analysis', 'cc900', 'corpus', 'firmware')

DECLS = """extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern unsigned char *DSP_TableWalk_Search(void *p, unsigned int key, unsigned int len, int *out);
"""

TUNE_TAIL = """    if (flag != 0) {
        switch (mode) {
        case 0:
            v--;
            break;
        case 1:
            v++;
            break;
        }
    }
    st = DSP_DispatchCommand(1, chip);
    st = DSP_DispatchData(1, chip);
    st = DSP_DispatchData(0x60, chip);
    st = DSP_DispatchData(0, chip);
    st = DSP_DispatchData(0, chip);
    st = DSP_DispatchData((unsigned char)(((v >> 4) & 0xf) + 0x10), chip);
    st = DSP_DispatchData((unsigned char)((v << 4) & 0xf0), chip);
    st = DSP_DispatchData(0, chip);
    st = DSP_DispatchData(0xa, chip);
    st = DSP_DispatchData((unsigned char)((P >> 17) & 0x7f), chip);
    st = DSP_DispatchData((unsigned char)((P >> 9) & 0xff), chip);
    st = DSP_DispatchData((unsigned char)((P >> 1) & 0xff), chip);
    st = DSP_DispatchData((unsigned char)(((P << 7) & 0x80) + 0x15), chip);
    st = DSP_DispatchCommand(3, chip);
    return st;
}
"""

TUNE_HEAD = 'int DSP_TuneOffset(long P, int chip, unsigned char *tbl, unsigned int mode, int flag)\n{\n'

RA = [
    ('p local after v, p = call; v = *p',
     '    int st;\n    unsigned int v;\n    unsigned int k = 0x79;\n    unsigned char *p;\n\n'
     '    p = DSP_TableWalk_Search(tbl, k, mode, &st);\n    v = *p;\n'),
    ('p local declared first',
     '    unsigned char *p;\n    int st;\n    unsigned int v;\n    unsigned int k = 0x79;\n\n'
     '    p = DSP_TableWalk_Search(tbl, k, mode, &st);\n    v = *p;\n'),
    ('register p',
     '    int st;\n    unsigned int v;\n    unsigned int k = 0x79;\n    register unsigned char *p;\n\n'
     '    p = DSP_TableWalk_Search(tbl, k, mode, &st);\n    v = *p;\n'),
    ('p initialised by the call',
     '    int st;\n    unsigned int v;\n    unsigned int k = 0x79;\n    unsigned char *p = DSP_TableWalk_Search(tbl, k, mode, &st);\n\n'
     '    v = *p;\n'),
    ('assignment inside the dereference: v = *(p = call)',
     '    int st;\n    unsigned int v;\n    unsigned int k = 0x79;\n    unsigned char *p;\n\n'
     '    v = *(p = DSP_TableWalk_Search(tbl, k, mode, &st));\n'),
    ('v = p[0]',
     '    int st;\n    unsigned int v;\n    unsigned int k = 0x79;\n    unsigned char *p;\n\n'
     '    p = DSP_TableWalk_Search(tbl, k, mode, &st);\n    v = p[0];\n'),
    ('p and a literal constant (no k)',
     '    int st;\n    unsigned int v;\n    unsigned char *p;\n\n'
     '    p = DSP_TableWalk_Search(tbl, 0x79, mode, &st);\n    v = *p;\n'),
    ('p as void * cast at the read',
     '    int st;\n    unsigned int v;\n    unsigned int k = 0x79;\n    void *p;\n\n'
     '    p = DSP_TableWalk_Search(tbl, k, mode, &st);\n    v = *(unsigned char *)p;\n'),
    ('p and a char temporary c = *p; v = c',
     '    int st;\n    unsigned int v;\n    unsigned int k = 0x79;\n    unsigned char *p;\n    unsigned char c;\n\n'
     '    p = DSP_TableWalk_Search(tbl, k, mode, &st);\n    c = *p;\n    v = c;\n'),
    ('k declared after p, p = call',
     '    int st;\n    unsigned int v;\n    unsigned char *p;\n    unsigned int k = 0x79;\n\n'
     '    p = DSP_TableWalk_Search(tbl, k, mode, &st);\n    v = *p;\n'),
    # round 15: the ROM's XDE is tbl's own register: the parameter reused for the result
    ('round 15: the parameter tbl reused, tbl = call; v = *tbl',
     '    int st;\n    unsigned int v;\n    unsigned int k = 0x79;\n\n'
     '    tbl = DSP_TableWalk_Search(tbl, k, mode, &st);\n    v = *tbl;\n'),
    ('round 15: v = *(tbl = call)',
     '    int st;\n    unsigned int v;\n    unsigned int k = 0x79;\n\n'
     '    v = *(tbl = DSP_TableWalk_Search(tbl, k, mode, &st));\n'),
    ('round 15: tbl reused, literal constant',
     '    int st;\n    unsigned int v;\n\n'
     '    tbl = DSP_TableWalk_Search(tbl, 0x79, mode, &st);\n    v = *tbl;\n'),
    ('round 15: tbl reused, v = tbl[0]',
     '    int st;\n    unsigned int v;\n    unsigned int k = 0x79;\n\n'
     '    tbl = DSP_TableWalk_Search(tbl, k, mode, &st);\n    v = tbl[0];\n'),
]

ALGO_HEAD = ('int DSP_AlgoDescriptor_Emit(unsigned int a, unsigned int sub, int chip, unsigned char *tbl, '
             'unsigned int type,\n                            unsigned int base, int unused)\n{\n')

ALGO_TAIL = """    st = DSP_DispatchCommand(1, chip);
    st = DSP_DispatchData(0, chip);
    st = DSP_DispatchData((unsigned char)v++, chip);
    if (type != 0x63) {
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData((unsigned char)(((base + a) >> 4) & 0xf), chip);
        st = DSP_DispatchData((unsigned char)(((base + a) << 4) & 0xf0), chip);
        st = DSP_DispatchData(0, chip);
    } else {
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0x20, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0, chip);
    }
    if (sub == 0) {
        st = DSP_DispatchData(8, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0x80, chip);
        st = DSP_DispatchData(0xb4, chip);
        st = DSP_DispatchData(7, chip);
    } else {
        st = DSP_DispatchData((unsigned char)(((v >> 7) & 2) + 0xc), chip);
        st = DSP_DispatchData((unsigned char)((v >> 7) & 1), chip);
        st = DSP_DispatchData((unsigned char)(v * 2), chip);
        st = DSP_DispatchData(4, chip);
        st = DSP_DispatchData(7, chip);
    }
    return st;
}
"""

CALL = 'DSP_TableWalk_Search(%s, %s, type, &st)'
CALL3 = 'DSP_TableWalk_Search(%s, %s, unused, &st)'
V3 = '    int st;\n    unsigned int v;\n'

RB = [
    ('k in an inner block around the call',
     V3 + '\n    {\n        unsigned int k = 0x78;\n        v = sub * 3 + (*' + CALL % ('tbl', 'k') + ' & 0xff);\n    }\n'),
    ('k declared first',
     '    unsigned int k = 0x78;\n' + V3 + '\n    v = sub * 3 + (*' + CALL % ('tbl', 'k') + ' & 0xff);\n'),
    ('t = tbl local pointer, k local',
     V3 + '    unsigned int k = 0x78;\n    unsigned char *t = tbl;\n\n    v = sub * 3 + (*' + CALL % ('t', 'k') + ' & 0xff);\n'),
    ('t = tbl local pointer, literal constant',
     V3 + '    unsigned char *t = tbl;\n\n    v = sub * 3 + (*' + CALL % ('t', '0x78') + ' & 0xff);\n'),
    ('returned pointer local p, literal constant',
     V3 + '    unsigned char *p;\n\n    p = ' + CALL % ('tbl', '0x78') + ';\n    v = sub * 3 + (*p & 0xff);\n'),
    ('returned pointer local p, k local',
     V3 + '    unsigned int k = 0x78;\n    unsigned char *p;\n\n    p = ' + CALL % ('tbl', 'k') +
     ';\n    v = sub * 3 + (*p & 0xff);\n'),
    ('k a signed int local',
     V3 + '    int k = 0x78;\n\n    v = sub * 3 + (*' + CALL % ('tbl', 'k') + ' & 0xff);\n'),
    ('k an unsigned char local',
     V3 + '    unsigned char k = 0x78;\n\n    v = sub * 3 + (*' + CALL % ('tbl', 'k') + ' & 0xff);\n'),
    ('k local and tbl cast to void *',
     V3 + '    unsigned int k = 0x78;\n\n    v = sub * 3 + (*' + CALL % ('(void *)tbl', 'k') + ' & 0xff);\n'),
    ('the constant through the unused parameter',
     V3 + '\n    unused = 0x78;\n    v = sub * 3 + (*' + CALL % ('tbl', 'unused') + ' & 0xff);\n'),
    ('k local assigned at the top, before the frame stores',
     V3 + '    unsigned int k;\n\n    k = 0x78;\n    v = sub * 3 + (*' + CALL % ('tbl', 'k') + ' & 0xff);\n'),
    ('the call first into w, then v = sub * 3 + w',
     V3 + '    unsigned int w;\n\n    w = *' + CALL % ('tbl', '0x78') + ' & 0xff;\n    v = sub * 3 + w;\n'),
    ('t = tbl and k both locals, t declared before k',
     V3 + '    unsigned char *t = tbl;\n    unsigned int k = 0x78;\n\n    v = sub * 3 + (*' + CALL % ('t', 'k') + ' & 0xff);\n'),
    ('register t = tbl, literal constant',
     V3 + '    register unsigned char *t = tbl;\n\n    v = sub * 3 + (*' + CALL % ('t', '0x78') + ' & 0xff);\n'),
    # round 15: the ROM's third argument is the LAST parameter (lowest stack offset, +14; type is at +18), not type
    ('round 15: third argument the last parameter, literal constant',
     V3 + '\n    v = sub * 3 + (*' + CALL3 % ('tbl', '0x78') + ' & 0xff);\n'),
    ('round 15: third argument the last parameter, k local',
     V3 + '    unsigned int k = 0x78;\n\n    v = sub * 3 + (*' + CALL3 % ('tbl', 'k') + ' & 0xff);\n'),
    ('round 15: third argument the last parameter, t = tbl and k locals',
     V3 + '    unsigned char *t = tbl;\n    unsigned int k = 0x78;\n\n    v = sub * 3 + (*' + CALL3 % ('t', 'k') +
     ' & 0xff);\n'),
    ('round 15: third argument the last parameter, returned pointer local p',
     V3 + '    unsigned char *p;\n\n    p = ' + CALL3 % ('tbl', '0x78') + ';\n    v = sub * 3 + (*p & 0xff);\n'),
]

HEADER = """/* spelling %s: %s */
/* lane_sub round 14, idiom probe %s (KN5000 sub-CPU payload v1.42, core/14_dsp_control_routines.s); written by
   notes/cc900-c-subcpu-2026-11-16/gen_r14_probes.py.  Only the spelling of the DSP_TableWalk_Search call varies. */

"""


def main():
    for tag, head, tail, items, what in (('ra', TUNE_HEAD, TUNE_TAIL, RA, '(XHL -> XDE copy), DSP_TuneOffset'),
                                         ('rb', ALGO_HEAD, ALGO_TAIL, RB, 'class (b) follow-up, DSP_AlgoDescriptor_Emit')):
        for i, (why, body) in enumerate(items, 1):
            n = '%02d' % i
            path = os.path.join(OUT, 'sub_F_%s%s.c' % (tag, n))
            with open(path, 'w') as fh:
                fh.write(HEADER % (n, why, what) + DECLS + '\n' + head + body + tail)
            print(os.path.relpath(path))


if __name__ == '__main__':
    main()
