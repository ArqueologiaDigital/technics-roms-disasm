/* lane_sub helper G, round 15, form b: the four functions that still missed in round 14 (KN5000 sub-CPU payload
   v1.42), each the best round-14 form changed only at its new first difference.
   DSP_WriteLUTParamSet: V4.23 gave the temporary pointer XBC and the switch byte A, the ROM has XWA and C; here the
     byte local c is declared BEFORE the pointer u (register order probe).
   EGEnv_Compute_A / _B: the ROM loads the curve word into WA and then widens it into XIZ; here an unsigned int
     temporary w receives the word and the long x is assigned from it.
   CustomTone_Apply_Catalog80: in its last store the ROM computes the value (into E) before the address; here a
     byte temporary t receives the value first.
   Form b: DSP_WriteLUTParamSet's byte local is plain (signed) char, still declared first; EGEnv chains
   `x = w = curve[u[1]];`; Catalog80 reuses its byte temporary u for the value instead of a new t. */

/* cc900-module: DSP_UnpackParam3B */
/* cc900-module: DSP_WriteFreqParam */
/* cc900-module: DSP_WriteCoeffData_5B */
/* cc900-module: CustomTone_CopyToneRecord */
/* cc900-module: CustomTone_CopySubUnitRecord */
/* cc900-module: EnvDepth_Cap */

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

int DSP_WriteLUTParamSet(unsigned char **pp, unsigned int b, long type, int chip, unsigned int base)
{
    unsigned int rows;
    unsigned int i;
    unsigned char *p;
    unsigned char *lut;
    int st;
    char c;
    unsigned char *u;

    u = *pp;
    p = u;
    c = *u++;
    p = u;
    switch (c) {
    default:
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
        break;
    case 1:
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
        break;
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

extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_RelBase;

struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };

extern void CustomTone_CopyToneRecord();
extern void CustomTone_CopySubUnitRecord();

/* cc900-name: CustomTone_Apply_Catalog80=VoiceParam_CustomTone_Apply_Catalog80 */
void CustomTone_Apply_Catalog80(unsigned int idx)
{
    unsigned char *rec;
    struct e16 *tbl;
    unsigned char e;
    unsigned char k;
    unsigned char *s;
    unsigned char u;
    e = u = ram_4531c[29351];
    rec = ram_4531c + ((int)u * 80 + 19111);
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 128));
    CustomTone_CopyToneRecord(tbl[idx].a, tbl[idx].b, e);
    for (k = 0; k < 2; k++) {
        s = rec + ((int)k * 21 + 16);
        CustomTone_CopySubUnitRecord(k, s[1], s[2], e);
        s[2] &= 15;
        s[2] |= 80;
    }
    ram_4531c[(int)e * 2 + 18855] = tbl[idx].a;
    u = (tbl[idx].b & 31) | 96;
    ((unsigned char *)(unsigned long)(ram_4531c + ((int)e * 2 + 18855)))[1] = u;
}

extern unsigned int EGEnv_BaseCurve_A[];
extern unsigned int EGEnv_BaseCurve_B[];
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned char ram_4424e[];
extern unsigned char ram_44257[];
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);

unsigned int EGEnv_Compute_A(unsigned char n)
{
    unsigned char *p;
    unsigned char *u;
    unsigned long x;
    unsigned int w;
    u = ram_4424e + (int)n * 27;
    p = u;
    x = w = EGEnv_BaseCurve_A[u[1]];
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
}

unsigned int EGEnv_Compute_B(unsigned char n)
{
    unsigned char *p;
    unsigned char *u;
    unsigned long x;
    unsigned int w;
    u = ram_44257 + (int)n * 27;
    p = u;
    x = w = EGEnv_BaseCurve_B[u[1]];
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
}
