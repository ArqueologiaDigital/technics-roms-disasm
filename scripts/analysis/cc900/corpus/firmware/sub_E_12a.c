/* lane_sub helper E, round 12, form a: the two bytecode switches of core/14_dsp_control_routines.s (KN5000 sub-CPU
   payload v1.42).  DSP_BytecodeInterpreter_Init holds the cases DSP_Bytecode_Op00_Groups5_ParamMix .. Op0E, and
   DSP_PerParameterTranslator holds DSP_Op_0x61_LinearEval .. DSP_Op_0x21_Interp2Point: those labels are case bodies,
   not functions.  The interpreter is round 5's (locals in the ROM's frame order: the first-declared stack local gets
   the LOWEST offset, as in round 4's form c), with the record field converted before it is added to t. */

/* cc900-data: DSP_BytecodeInterpreter_Init 1 = DSP_BytecodeInterpreter_CaseOffsets */
/* cc900-data: DSP_PerParameterTranslator 1 = DSP_Translator_CaseOffsets */
/* cc900-module: DSP_Bytecode_NotifyStateChange DSP_TableWalk_Search */

struct bcfg { int a; int b; int c; int d; long e; };

extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
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

int DSP_BytecodeInterpreter_Init(int chip, unsigned int idx, struct bcfg *cfg, unsigned char *code)
{
    int st;
    unsigned int t;
    unsigned int op;
    unsigned int i;
    unsigned int len;
    int f0;
    int f1;
    int f2;
    int f3;
    long f4;

    f0 = cfg[idx].a;
    f1 = cfg[idx].b;
    f2 = cfg[idx].c;
    f3 = cfg[idx].d;
    f4 = cfg[idx].e;
    while ((*code & 0xf0) != 0xf0) {
        op = *code & 0xf0;
        len = ((int)(*code & 0xf) << 8) + (int)(code[1] & 0xff) - 2;
        code = code + 2;
        switch (op >> 4) {
        case 0:
            st = DSP_DispatchCommand(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            for (i = 1; i <= (len - 3) / 5; i++) {
                if (*code == 0) {
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                    t = ((unsigned int)code[0] << 4) + ((code[1] >> 4) & 0xf);
                    t += (unsigned int)f1;
                    st = DSP_DispatchData((unsigned char)((t >> 4) & 0xff), chip);
                    st = DSP_DispatchData((unsigned char)((t << 4) & 0xff), chip);
                    code = code + 2;
                    st = DSP_DispatchData(*code++, chip);
                } else if (*code == 10) {
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                } else {
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData((unsigned char)(code[0] + ((f4 >> 17) & 0x7f)), chip);
                    st = DSP_DispatchData((unsigned char)(code[1] + ((f4 >> 9) & 0xff)), chip);
                    st = DSP_DispatchData((unsigned char)(code[2] + ((f4 >> 1) & 0xff)), chip);
                    st = DSP_DispatchData((unsigned char)(code[3] + ((f4 << 7) & 0x80)), chip);
                    code = code + 4;
                }
            }
            break;
        case 1:
            st = DSP_DispatchCommand(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            for (i = 1; i <= (len - 3) / 5; i++) {
                st = DSP_DispatchData(*code++, chip);
                st = DSP_DispatchData(*code++, chip);
                t = ((unsigned int)code[0] << 4) + ((code[1] >> 4) & 0xf);
                t += (unsigned int)f0;
                st = DSP_DispatchData((unsigned char)((t >> 4) & 0xff), chip);
                st = DSP_DispatchData((unsigned char)(((t << 4) & 0xff) + 8), chip);
                code = code + 2;
                st = DSP_DispatchData(*code++, chip);
            }
            break;
        case 2:
            st = DSP_DispatchCommand(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            for (i = 1; i <= (len - 3) / 3; i++) {
                st = DSP_DispatchData(*code++, chip);
                st = DSP_DispatchData(*code++, chip);
                st = DSP_DispatchData(*code++, chip);
            }
            break;
        case 3:
            st = DSP_DispatchCommand(*code++, chip);
            t = ((unsigned int)code[0] << 8) + (code[1] & 0xff);
            t += (unsigned int)f3;
            st = DSP_DispatchData((unsigned char)((t >> 8) & 0xff), chip);
            st = DSP_DispatchData((unsigned char)(t & 0xff), chip);
            code = code + 2;
            for (i = 1; i <= len - 3; i++)
                st = DSP_DispatchData(*code++, chip);
            break;
        case 4:
            st = DSP_DispatchCommand(*code++, chip);
            break;
        case 5:
            st = DSP_DispatchCommand(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            for (i = 1; i <= (len - 3) / 5; i++) {
                if (*code == 8) {
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                    t = ((unsigned int)code[0] << 4) + ((code[1] >> 4) & 0xf);
                    t += (unsigned int)f2;
                    t &= 0xff;
                    st = DSP_DispatchData((unsigned char)((t >> 4) & 0xff), chip);
                    st = DSP_DispatchData((unsigned char)(((t << 4) & 0xff) + 8), chip);
                    code = code + 2;
                    st = DSP_DispatchData(*code++, chip);
                } else {
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData((unsigned char)(code[0] + ((f4 >> 17) & 0x7f)), chip);
                    st = DSP_DispatchData((unsigned char)(code[1] + ((f4 >> 9) & 0xff)), chip);
                    st = DSP_DispatchData((unsigned char)(code[2] + ((f4 >> 1) & 0xff)), chip);
                    st = DSP_DispatchData((unsigned char)(code[3] + ((f4 << 7) & 0x80)), chip);
                    code = code + 4;
                }
            }
            break;
        case 0xd:
            DSP2_SPI_BusIdle();
            DSP_Bytecode_NotifyStateChange();
            break;
        case 0xe:
            st = DSP_DispatchCommand(*code++, chip);
            for (i = 1; i <= len - 1; i++)
                st = DSP_DispatchData(*code++, chip);
            break;
        }
    }
    return st;
}

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
