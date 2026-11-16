/* lane_sub helper E, round 7, form c: DSP_WriteLUTParamSet (KN5000 sub-CPU payload v1.42), kept apart because the
   ROM uses the results of DSP_WriteFreqParam / DSP_WriteCoeffData_5B (`ld iz,hl`) and passes the coefficient writer
   a third argument (`ld de,..`), which the other probe files' definitions of those functions do not have.  Round 7:
   the locals declared in the ROM's frame order, *pp read and post-incremented in one expression; and
   DSP_WriteParameter with the record address computed as an integer (the ROM's 32-bit `add xde,xix`). */

/* cc900-module: DSP_UnpackParam3B DSP_WriteFreqParam DSP_WriteCoeffData_5B */

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

    switch ((p = *pp, *p++)) {
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

struct bcfg { int a; int b; int c; int d; long e; };
struct pblk;

extern struct bcfg ToneGen_WorkArea[];
extern unsigned char DSP_Eff9_Param_Descriptors[];
extern unsigned char DSP_Eff9_Param_Values[];
extern unsigned char DSP_EffA_Param_Descriptors[];
extern unsigned char DSP_EffA_Param_Values[];
extern unsigned char *DSP_Param_Block_Ptrs_A[];
extern unsigned char *DSP_Param_Block_Ptrs_B[];
extern void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, void *desc, void *vals, int v,
                                     unsigned char *rec);

void DSP_WriteParameter(unsigned int slot, unsigned int type, int v, struct pblk *p)
{
    if (slot == 1 && (type == 9 || type == 10)) {
        switch (type) {
        case 9:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Eff9_Param_Descriptors, DSP_Eff9_Param_Values, v,
                                     (unsigned char *)((unsigned long)slot * 56 + 8 + (unsigned long)p) + 4);
            break;
        case 10:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_EffA_Param_Descriptors, DSP_EffA_Param_Values, v,
                                     (unsigned char *)((unsigned long)slot * 56 + 8 + (unsigned long)p) + 4);
            break;
        }
    } else {
        DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Param_Block_Ptrs_B[type], DSP_Param_Block_Ptrs_A[type],
                                 v, (unsigned char *)((unsigned long)slot * 56 + 8 + (unsigned long)p) + 4);
    }
}
