#!/usr/bin/env python3
"""Write lane_sub helper L's round-16 files sub_L_16a.c .. sub_L_16d.c (KN5000 sub-CPU payload v1.42).

QUESTION ANSWERED: which C spelling makes V4.23 (-Xr) give the ROM's register choice in
  DSP_AlgoDescriptor_Emit  (tbl held in XHL across the DSP_TableWalk_Search call, constant in BC before &st),
  DSP_WriteLUTParamSet     (the selector byte compared in C, no copy to A),
  DSP_ParamInterp_Div0xC6  (the product copied XHL -> XWA, the result built in XHL),
  DSP_MixSendConfig        (the returned pointer copied XHL -> XBC, n in HL, i in DE).

    python3 -B gen_L_16.py /home/fsanches/compartilhado/disasm-lanes/csub
writes scripts/analysis/cc900/corpus/firmware/sub_L_16{a,b,c,d}.c under that root.
"""
import os
import sys

HEAD = """/* lane_sub helper L, round 16, form %(form)s (KN5000 sub-CPU payload v1.42); written by gen_L_16.py.
   DSP_AlgoDescriptor_Emit: %(algo_why)s
   DSP_WriteLUTParamSet: %(lut_why)s
   DSP_ParamInterp_Div0xC6: %(interp_why)s
   DSP_MixSendConfig: %(mix_why)s */

/* cc900-module: DSP_UnpackParam3B */
/* cc900-module: DSP_WriteFreqParam */
/* cc900-module: DSP_WriteCoeffData_5B */

extern unsigned char DSP_Op74_LUT_Rows9_Var0[];
extern unsigned char DSP_Op74_LUT_Rows9_Var1[];
extern unsigned char DSP_Op74_LUT_Rows9_Var2[];
extern unsigned char DSP_Op74_LUT_Rows8_Var0[];
extern unsigned char DSP_Op74_LUT_Rows8_Var1[];
extern unsigned char DSP_Op74_LUT_Rows8_Var2[];

extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern long DSP_UnpackParam3B(unsigned char **pp);
extern int DSP_WriteFreqParam(unsigned int a, long v, int chip, unsigned int base);
extern int DSP_WriteCoeffData_5B(long v, int chip, unsigned int base);
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
%(search_decl)s
%(find_decl)s

"""

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

SEARCH_VOID = 'extern unsigned char *DSP_TableWalk_Search(void *p, unsigned int key, unsigned int len, int *out);'
SEARCH_UC = 'extern unsigned char *DSP_TableWalk_Search(unsigned char *p, unsigned int key, unsigned int len, int *out);'
USE = '    v = sub * 3 + (*p & 0xff);\n'

ALGO = {
    'a': ('a pointer local p starts as tbl and receives the result (p = f(p, k, unused, &st)); k an unsigned local.',
          SEARCH_VOID,
          '    int st;\n    unsigned int v;\n    unsigned char *p = tbl;\n    unsigned int k = 0x78;\n\n'
          '    p = DSP_TableWalk_Search(p, k, unused, &st);\n' + USE),
    'b': ('form a with k a SIGNED int local (in probe rb07 a signed k was loaded straight into BC).',
          SEARCH_VOID,
          '    int st;\n    unsigned int v;\n    unsigned char *p = tbl;\n    int k = 0x78;\n\n'
          '    p = DSP_TableWalk_Search(p, k, unused, &st);\n' + USE),
    'c': ('form a with the literal constant, no k.',
          SEARCH_VOID,
          '    int st;\n    unsigned int v;\n    unsigned char *p = tbl;\n\n'
          '    p = DSP_TableWalk_Search(p, 0x78, unused, &st);\n' + USE),
    'd': ('form b with k declared before p, both assigned by statements (p first), the callee prototyped with\n'
          '     unsigned char *.',
          SEARCH_UC,
          '    int st;\n    unsigned int v;\n    int k;\n    unsigned char *p;\n\n'
          '    p = tbl;\n    k = 0x78;\n    p = DSP_TableWalk_Search(p, k, unused, &st);\n' + USE),
}

LUT_HEAD = 'int DSP_WriteLUTParamSet(unsigned char **pp, unsigned int b, long type, int chip, unsigned int base)\n{\n'

LUT_DECL_C = ('    unsigned char c;\n    unsigned char *u;\n    unsigned int rows;\n    unsigned int i;\n'
              '    unsigned char *p;\n    unsigned char *lut;\n    int st;\n\n')
LUT_DECL_A = ('    unsigned int rows;\n    unsigned int i;\n    unsigned char *p;\n    unsigned char *lut;\n'
              '    int st;\n    unsigned char c;\n    unsigned char *u;\n\n')

INNER9 = """        rows = 0x24;
        switch (type) {
        default:
            lut = DSP_Op74_LUT_Rows9_Var0;
            break;
        case 1:
            lut = DSP_Op74_LUT_Rows9_Var1;
            break;
        case 2:
            lut = DSP_Op74_LUT_Rows9_Var2;
            break;
        }
"""
INNER8 = INNER9.replace('0x24', '0x20').replace('Rows9', 'Rows8')

LUT_IF = '%s' + INNER9 + '    } else {\n' + INNER8 + '    }\n'
LUT_SWITCH = '%s    default:\n' + INNER9 + '        break;\n    case 1:\n' + INNER8 + '        break;\n    }\n'

LUT_TAIL = """    b = *lut++;
    for (i = 0; i < rows >> 2; i++) {
        if (i != 0) {
            st = DSP_DispatchCommand(1, chip);
            st = DSP_DispatchData(1, chip);
            st = DSP_DispatchData(0x60, chip);
        }
        st = DSP_WriteFreqParam((i << 2) + b, DSP_UnpackParam3B(&lut), chip, base);
        st = DSP_WriteCoeffData_5B(DSP_UnpackParam3B(&lut), chip, base);
        st = DSP_WriteCoeffData_5B(DSP_UnpackParam3B(&lut), chip, base);
        st = DSP_WriteCoeffData_5B(DSP_UnpackParam3B(&lut), chip, base);
        DSP_DispatchCommand(3, chip);
    }
    *pp = p;
    return st;
}

"""

PRE = '    u = *pp;\n    p = u;\n    c = *u++;\n    p = u;\n'
LUT = {
    'a': ('sub_G_15c.c with the outer two-way switch written as if (c != 1) { 0x24 rows } else { 0x20 rows }.',
          LUT_DECL_C + PRE + LUT_IF % '    if (c != 1) {\n'),
    'b': ('form a with the byte read inside the test: if ((c = *u++, p = u, c) != 1).',
          LUT_DECL_C + '    u = *pp;\n    p = u;\n' + LUT_IF % '    if ((c = *u++, p = u, c) != 1) {\n'),
    'c': ('sub_G_15c.c, the outer switch kept, on (unsigned char)c.',
          LUT_DECL_C + PRE + LUT_SWITCH % '    switch ((unsigned char)c) {\n'),
    'd': ('form a with the locals in sub_G_15a.c\'s order (c and u declared last).',
          LUT_DECL_A + PRE + LUT_IF % '    if (c != 1) {\n'),
}

INTERP_HEAD = 'long DSP_ParamInterp_Div0xC6(unsigned char **pp, long b)\n{\n    long v0;\n    long v1;\n    unsigned char *p;\n'
INTERP_MID = """
    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    t = b;
    t += 0x63;
    q = ((v1 - v0) >> 8) / 0xc6;
"""
INTERP_TAIL = '    *pp = p;\n    return r;\n}\n\n'

INTERP = {
    'a': ('the product through a long local m: m = q * t; r = (v0 >> 8) + m.',
          '    long t;\n    long q;\n    long r;\n    long m;\n',
          '    m = q * t;\n    r = (v0 >> 8) + m;\n'),
    'b': ('the product converted in the sum: r = (v0 >> 8) + (long)(unsigned long)(q * t).',
          '    long t;\n    long q;\n    long r;\n',
          '    r = (v0 >> 8) + (long)(unsigned long)(q * t);\n'),
    'c': ('the product through an unsigned long local m: m = q * t; r = (v0 >> 8) + (long)m.',
          '    long t;\n    long q;\n    long r;\n    unsigned long m;\n',
          '    m = q * t;\n    r = (v0 >> 8) + (long)m;\n'),
    'd': ('t an unsigned long (an unsigned product): r = (v0 >> 8) + (long)(q * t).',
          '    unsigned long t;\n    long q;\n    long r;\n',
          '    r = (v0 >> 8) + (long)(q * t);\n'),
}

MIX_LOOP = '    n = 0x11;\n    for (i = 0; i < n; i++)\n        *d++ = *s++;\n}\n'
FIND_PTR = 'extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned char *b);'
FIND_INT = 'extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);'
FIND_KR = 'extern unsigned char *ToneDB_Find_ToneRecord();'
MIX_PTR_HEAD = 'void DSP_MixSendConfig(unsigned int a, unsigned char *s, unsigned char *d)\n{\n'

MIX = {
    'a': ('idiom (e) on the SECOND parameter: it is a pointer s (XBC) and receives the result, s = f(a, s); the\n'
          '     callee prototyped (unsigned int, unsigned char *); n declared before i.',
          FIND_PTR,
          MIX_PTR_HEAD + '    unsigned int n;\n    unsigned int i;\n\n    s = ToneDB_Find_ToneRecord(a, s);\n' + MIX_LOOP),
    'b': ('form a with the callee declared without a prototype.',
          FIND_KR,
          MIX_PTR_HEAD + '    unsigned int n;\n    unsigned int i;\n\n    s = ToneDB_Find_ToneRecord(a, s);\n' + MIX_LOOP),
    'c': ('form a with i declared before n.',
          FIND_PTR,
          MIX_PTR_HEAD + '    unsigned int i;\n    unsigned int n;\n\n    s = ToneDB_Find_ToneRecord(a, s);\n' + MIX_LOOP),
    'd': ('the second parameter a long c passed as (unsigned int)c, the result kept in it and read through a cast:\n'
          '     c = (long)f(a, (unsigned int)c); the copy reads *(unsigned char *)c and then c++.',
          FIND_INT,
          'void DSP_MixSendConfig(unsigned int a, long c, unsigned char *d)\n{\n'
          '    unsigned int n;\n    unsigned int i;\n\n'
          '    c = (long)ToneDB_Find_ToneRecord(a, (unsigned int)c);\n'
          '    n = 0x11;\n    for (i = 0; i < n; i++) {\n        *d++ = *(unsigned char *)c;\n        c++;\n    }\n}\n'),
}


def main():
    root = sys.argv[1]
    out = os.path.join(root, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware')
    assert os.path.isdir(out), out
    for form in 'abcd':
        algo_why, search_decl, algo_body = ALGO[form]
        lut_why, lut_body = LUT[form]
        interp_why, interp_decl, interp_body = INTERP[form]
        mix_why, find_decl, mix_body = MIX[form]
        text = HEAD % dict(form=form, algo_why=algo_why, lut_why=lut_why, interp_why=interp_why, mix_why=mix_why,
                           search_decl=search_decl, find_decl=find_decl)
        text += ALGO_HEAD + algo_body + ALGO_TAIL
        text += LUT_HEAD + lut_body + LUT_TAIL
        text += INTERP_HEAD + interp_decl + INTERP_MID + interp_body + INTERP_TAIL
        text += mix_body
        path = os.path.join(out, 'sub_L_16%s.c' % form)
        with open(path, 'w') as fh:
            fh.write(text)
        print(path)


if __name__ == '__main__':
    main()
