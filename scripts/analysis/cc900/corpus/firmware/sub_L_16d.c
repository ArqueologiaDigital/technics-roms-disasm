/* lane_sub helper L, round 16, form d (KN5000 sub-CPU payload v1.42); written by gen_L_16.py.
   DSP_AlgoDescriptor_Emit: form b with k declared before p, both assigned by statements (p first), the callee prototyped with
     unsigned char *.
   DSP_WriteLUTParamSet: form a with the locals in sub_G_15a.c's order (c and u declared last).
   DSP_ParamInterp_Div0xC6: t an unsigned long (an unsigned product): r = (v0 >> 8) + (long)(q * t).
   DSP_MixSendConfig: the second parameter a long c passed as (unsigned int)c, the result kept in it and read through a cast:
     c = (long)f(a, (unsigned int)c); the copy reads *(unsigned char *)c and then c++. */

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
extern unsigned char *DSP_TableWalk_Search(unsigned char *p, unsigned int key, unsigned int len, int *out);
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);

int DSP_AlgoDescriptor_Emit(unsigned int a, unsigned int sub, int chip, unsigned char *tbl, unsigned int type,
                            unsigned int base, int unused)
{
    int st;
    unsigned int v;
    int k;
    unsigned char *p;

    p = tbl;
    k = 0x78;
    p = DSP_TableWalk_Search(p, k, unused, &st);
    v = sub * 3 + (*p & 0xff);
    st = DSP_DispatchCommand(1, chip);
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

int DSP_WriteLUTParamSet(unsigned char **pp, unsigned int b, long type, int chip, unsigned int base)
{
    unsigned int rows;
    unsigned int i;
    unsigned char *p;
    unsigned char *lut;
    int st;
    unsigned char c;
    unsigned char *u;

    u = *pp;
    p = u;
    c = *u++;
    p = u;
    if (c != 1) {
        rows = 0x24;
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
    } else {
        rows = 0x20;
        switch (type) {
        default:
            lut = DSP_Op74_LUT_Rows8_Var0;
            break;
        case 1:
            lut = DSP_Op74_LUT_Rows8_Var1;
            break;
        case 2:
            lut = DSP_Op74_LUT_Rows8_Var2;
            break;
        }
    }
    b = *lut++;
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

long DSP_ParamInterp_Div0xC6(unsigned char **pp, long b)
{
    long v0;
    long v1;
    unsigned char *p;
    unsigned long t;
    long q;
    long r;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    t = b;
    t += 0x63;
    q = ((v1 - v0) >> 8) / 0xc6;
    r = (v0 >> 8) + (long)(q * t);
    *pp = p;
    return r;
}

void DSP_MixSendConfig(unsigned int a, long c, unsigned char *d)
{
    unsigned int n;
    unsigned int i;

    c = (long)ToneDB_Find_ToneRecord(a, (unsigned int)c);
    n = 0x11;
    for (i = 0; i < n; i++) {
        *d++ = *(unsigned char *)c;
        c++;
    }
}
