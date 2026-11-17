/* Functions of core/14_dsp_control_routines.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct bcfg { int a; int b; int c; int d; long e; };
extern void DSP_WriteParamCmd30(int chip, unsigned int b, long v);
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
extern int DSP_DispatchData(int d, int chip);
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
extern int DSP_WriteOscParam(unsigned int a, long v, register int chip, int base);
extern int DSP_WriteFreqParam(unsigned int a, long v, int chip, int base);
extern int DSP_WriteFreqParam_AlgoType(unsigned int a, long v, int chip, int base);
extern int DSP_WriteOscParam_Offset(unsigned int a, long v, register int chip, int base, long off);
long DSP_ParamInterp_Div0xB4(unsigned char **pp, long b);
unsigned char *DSP_PerParameterTranslator(int chip, unsigned int slot, unsigned int v, unsigned char *p,
                                          unsigned char *desc, int *rec, struct bcfg *work, int *status);
int DSP_WriteOscParam(unsigned int a, long v, register int chip, int base);
int DSP_WriteOscParam_Offset(unsigned int a, long v, register int chip, int base, long off);

/* cc900-module: DSP_Bytecode_NotifyStateChange DSP_TableWalk_Search DSP_WriteParamCmd30 */
/* cc900-data: DSP_PerParameterTranslator 1 = DSP_Translator_CaseOffsets */
long DSP_ParamInterp_Div0xB4(unsigned char **pp, long b)
{
    long v;
    unsigned char *p;
    long r;
    long u;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v);
    u = (v >> 8) & 0xffffff;
    v = u;
    r = u * b / 0xb4;
    *pp = p;
    return r;
}

unsigned char *DSP_PerParameterTranslator(int chip, unsigned int slot, unsigned int v, unsigned char *p,
                                          unsigned char *desc, int *rec, struct bcfg *work, int *status)
{
    int f0;
    int f1;
    int f2;
    long f4;
    int st;
    unsigned int a;
    unsigned int op;
    unsigned char *d;
    long x;

    f0 = work[slot].a;
    f1 = work[slot].b;
    f2 = work[slot].c;
    f4 = work[slot].e;
    while ((op = *p++) != 0x7a) {
        d = DSP_TableWalk_Search(desc, op, *p++, &st);
        if (st != 0)
            goto out;
        a = *d;
        x = rec[v];
        switch (op) {
        case 0x61:
            st = DSP_WriteOscParam(a, DSP_ParamFetch_Op61Table(&p, x), chip, f0);
            break;
        case 0x62:
            st = DSP_WriteOscParam(a, DSP_ParamFetch_SingleTable(&p, x), chip, f0);
            break;
        case 0x63:
            st = DSP_WriteFreqParam_AlgoType(a, DSP_ParamFetch_AlgoTypeTable(&p, x), chip, f1);
            break;
        case 0x79:
            st = DSP_WriteOscParam(a, DSP_AlgoParam_Decode(&p, x), chip, f0);
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
        case 0x40:
            st = DSP_WriteOscParam(a, DSP_PanScale_Simple(&p, x), chip, f0);
            break;
        case 0x24:
            st = DSP_WriteOscParam(a, DSP_ParamInterp_MultiStep(&p, x, rec, slot, v), chip, f0);
            break;
        case 0x21:
            st = DSP_WriteOscParam(a, DSP_ParamInterp_2Point(&p, x), chip, f0);
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

int DSP_WriteOscParam(unsigned int a, long v, register int chip, int base)
{
    switch (chip) {
    default:
            DSP_DispatchData(8, chip);
            DSP_DispatchData(1, chip);
            DSP_DispatchData((unsigned char)(((base + a) >> 4) & 0xf), chip);
            DSP_DispatchData((unsigned char)((((base + a) << 4) & 0xf0) + 8), chip);
            DSP_DispatchData(0x21, chip);
            DSP_DispatchData(0xa, chip);
            DSP_DispatchData((unsigned char)((v >> 17) & 0x7f), chip);
            DSP_DispatchData((unsigned char)((v >> 9) & 0xff), chip);
            DSP_DispatchData((unsigned char)((v >> 1) & 0xff), chip);
            DSP_DispatchData((unsigned char)(((v << 7) & 0x80) + 0x26), chip);
        break;
    case 1:
            DSP_WriteParamCmd30(chip, a, v);
        break;
    }
}

int DSP_WriteOscParam_Offset(unsigned int a, long v, register int chip, int base, long off)
{
    DSP_DispatchData(8, chip);
    DSP_DispatchData(1, chip);
    DSP_DispatchData((unsigned char)(((base + a) >> 4) & 0xf), chip);
    DSP_DispatchData((unsigned char)((((base + a) << 4) & 0xf0) + 8), chip);
    DSP_DispatchData(0x25, chip);
    v += off;
    DSP_DispatchData(0xa, chip);
    DSP_DispatchData((unsigned char)((v >> 17) & 0x7f), chip);
    DSP_DispatchData((unsigned char)((v >> 9) & 0xff), chip);
    DSP_DispatchData((unsigned char)((v >> 1) & 0xff), chip);
    DSP_DispatchData((unsigned char)(((v << 7) & 0x80) + 0x4c), chip);
}
