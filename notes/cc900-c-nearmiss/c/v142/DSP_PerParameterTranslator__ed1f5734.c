/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_12b.c (2026-11-16-97-sub-r12)
   sha256 ed1f57340ab76dc5e5d878eaad8ad5c3c6d4dc21515f8f7fc9a85dabbb0fa062 (name+funcs); compiled at -Xr */
struct bcfg { int a; int b; int c; int d; long e; };
extern void DSP2_SPI_BusIdle(void);
extern void DSP_Bytecode_NotifyStateChange(void);
extern unsigned char *DSP_TableWalk_Search(unsigned char *p, unsigned int key, unsigned int len, int *out);
extern long DSP_ParamFetch_Op61Table(unsigned char **pp, long x);
extern long DSP_ParamFetch_SingleTable(unsigned char **pp, long x);
extern long DSP_ParamFetch_AlgoTypeTable(unsigned char **pp, long x);
extern long DSP_AlgoParam_Decode(unsigned char **pp, long x);
extern long DSP_PitchParam_Scale(unsigned char **pp, long x);
extern long DSP_VolumeParam_Scale(unsigned char **pp, long x);
extern long DSP_ParamInterp_2Point(unsigned char **pp, long x);
extern long DSP_ParamInterp_FPScale(unsigned char **pp, long x);
extern long DSP_ParamInterp_Div0xB4(unsigned char **pp, long x);
extern long DSP_VolumeCurve_FP(unsigned char **pp, long x);
extern long DSP_FreqCurve_FP(unsigned char **pp, long x);
extern long DSP_FreqInterp_2Point(unsigned char **pp, long x);
extern long DSP_ParamInterp_3Point_WithOffset(unsigned char **pp, long x, long c);
extern long DSP_ReverbCurve_FP(unsigned char **pp, long x);
extern long DSP_ParamInterp_FPComplex(unsigned char **pp, long x);
extern long DSP_PanCurve_PiecewiseLin(unsigned char **pp, long x);
extern long DSP_DetuneCurve_SignedFP(unsigned char **pp, long x);
extern long DSP_ParamInterp_Div0xC6(unsigned char **pp, long x);
extern long DSP_ParamEQ_Curve_FP(unsigned char **pp, long x);
extern long DSP_ParamInterp_2Point_B(unsigned char **pp, long x);
extern long DSP_VolScale_B(unsigned char **pp, long x);
extern long DSP_PanScale_Simple(unsigned char **pp, long x);
extern long DSP_ParamInterp_MultiStep(unsigned char **pp, long x, int *tbl, unsigned int slot, unsigned int v);
extern unsigned char *DSP_BiquadCoeff_Compute(int chip, unsigned int slot, unsigned int v, unsigned char *p,
                                              unsigned int a, int *rec, int f0, int *st);
extern unsigned char *DSP_SOS_Coeff_Compute(int chip, unsigned int slot, unsigned int v, unsigned char *p,
                                            unsigned int a, int *rec, int *st, int f0);
extern int DSP_BiquadWarp_FP(unsigned char **pp, int *rec, unsigned int slot, unsigned int v, unsigned int a,
                             int chip, int f0);
extern int DSP_WriteLUTParamSet(unsigned char **pp, unsigned int b, long type, int chip, int base);
extern int DSP_WriteOscParam(unsigned int a, long v, int chip, int base);
extern int DSP_WriteFreqParam(unsigned int a, long v, int chip, int base);
extern int DSP_WriteFreqParam_AlgoType(unsigned int a, long v, int chip, int base);
extern int DSP_WriteOscParam_Offset(unsigned int a, long v, int chip, int base, long off);
unsigned char *DSP_PerParameterTranslator(int chip, unsigned int slot, unsigned int v, unsigned char *p,
                                          unsigned char *desc, int *rec, struct bcfg *work, int *status)
{
    int f0;
    int f1;
    int f2;
    long f4;
    int st;
    unsigned int op;
    unsigned int a;
    unsigned char *d;
    long x;

    f0 = work[slot].a;
    f1 = work[slot].b;
    f2 = work[slot].c;
    f4 = work[slot].e;
    while ((op = *p++) != 0x7a) {
        d = DSP_TableWalk_Search(desc, op, *p++, &st);
        if (st != 0)
            break;
        a = *d;
        x = rec[v];
        switch (op) {
        case 0x21:
            st = DSP_WriteOscParam(a, DSP_ParamInterp_2Point(&p, x), chip, f0);
            break;
        case 0x24:
            st = DSP_WriteOscParam(a, DSP_ParamInterp_MultiStep(&p, x, rec, slot, v), chip, f0);
            break;
        case 0x40:
            st = DSP_WriteOscParam(a, DSP_PanScale_Simple(&p, x), chip, f0);
            break;
        case 0x61:
            st = DSP_WriteOscParam(a, DSP_ParamFetch_Op61Table(&p, x), chip, f0);
            break;
        case 0x62:
            st = DSP_WriteOscParam(a, DSP_ParamFetch_SingleTable(&p, x), chip, f0);
            break;
        case 0x63:
            st = DSP_WriteFreqParam_AlgoType(a, DSP_ParamFetch_AlgoTypeTable(&p, x), chip, f1);
            break;
        case 0x64:
            st = DSP_WriteFreqParam(a, DSP_PitchParam_Scale(&p, x), chip, f1);
            break;
        case 0x65:
            st = DSP_WriteOscParam(a, DSP_VolumeParam_Scale(&p, x), chip, f0);
            break;
        case 0x66:
            st = DSP_WriteOscParam(a, DSP_ParamInterp_2Point(&p, x), chip, f0);
            break;
        case 0x67:
            st = DSP_WriteOscParam_Offset(a, DSP_ParamInterp_FPScale(&p, x), chip, f2, f4);
            break;
        case 0x68:
            st = DSP_WriteFreqParam(a, DSP_ParamInterp_Div0xB4(&p, x), chip, f1);
            break;
        case 0x69:
            st = DSP_WriteOscParam(a, DSP_VolumeCurve_FP(&p, x), chip, f0);
            break;
        case 0x6a:
            st = DSP_WriteFreqParam(a, DSP_FreqCurve_FP(&p, x), chip, f1);
            break;
        case 0x6b:
            st = DSP_WriteFreqParam(a, DSP_FreqInterp_2Point(&p, x), chip, f1);
            break;
        case 0x6c:
            st = DSP_WriteFreqParam(a, DSP_ParamInterp_3Point_WithOffset(&p, x, f4), chip, f1);
            break;
        case 0x6d:
            st = DSP_WriteOscParam(a, DSP_ReverbCurve_FP(&p, x), chip, f0);
            break;
        case 0x6e:
            st = DSP_WriteOscParam(a, DSP_ParamInterp_FPComplex(&p, x), chip, f0);
            break;
        case 0x6f:
            st = DSP_WriteOscParam(a, DSP_PanCurve_PiecewiseLin(&p, x), chip, f0);
            break;
        case 0x70:
            p = DSP_BiquadCoeff_Compute(chip, slot, v, p, a, rec, f0, &st);
            break;
        case 0x71:
            st = DSP_WriteOscParam(a, DSP_DetuneCurve_SignedFP(&p, x), chip, f0);
            break;
        case 0x72:
            st = DSP_BiquadWarp_FP(&p, rec, slot, v, a, chip, f0);
            break;
        case 0x73:
            st = DSP_WriteOscParam(a, DSP_ParamInterp_Div0xC6(&p, x), chip, f0);
            break;
        case 0x74:
            st = DSP_WriteLUTParamSet(&p, a, x, chip, f1);
            break;
        case 0x75:
            st = DSP_WriteOscParam(a, DSP_ParamEQ_Curve_FP(&p, x), chip, f0);
            break;
        case 0x76:
            p = DSP_SOS_Coeff_Compute(chip, slot, v, p, a, rec, &st, f0);
            break;
        case 0x77:
            st = DSP_WriteOscParam(a, DSP_ParamInterp_2Point_B(&p, x), chip, f0);
            break;
        case 0x78:
            st = DSP_WriteOscParam(a, DSP_VolScale_B(&p, x), chip, f0);
            break;
        case 0x79:
            st = DSP_WriteOscParam(a, DSP_AlgoParam_Decode(&p, x), chip, f0);
            break;
        default:
            st = 5;
            goto out;
        }
        if (chip == 1) {
            DSP2_SPI_BusIdle();
            DSP_Bytecode_NotifyStateChange();
        }
    }
out:
    *status = st;
    return p;
}
