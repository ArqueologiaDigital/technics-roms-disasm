/* lane_sub helper E, round 8, form c: DSP_WriteLUTParamSet (KN5000 sub-CPU payload v1.42).  Kept apart because the
   ROM uses the results of DSP_WriteFreqParam / DSP_WriteCoeffData_5B (`ld iz,hl`) and passes the coefficient writer a
   third argument (`ld de,..`).  Round 7's frame order matched; this form initialises p in its declaration, since
   V4.23 reloaded p between `p = *pp` and `*p++` where the ROM keeps it in XWA. */

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
    unsigned char *p = *pp;
    unsigned char *lut;
    int st;

    switch (*p++) {
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
