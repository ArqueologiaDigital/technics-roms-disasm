/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/fdc_routines_m270_xr.c (2026-11-16-111-p6-r22-staged)
   sha256 a035e841d7293846b48f030e11358e6f4ccc7537fd96ee1103796cf870c21472 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __near FDC_SPECIFY_SRT;
extern unsigned char __near FDC_SPECIFY_HUT;
extern unsigned char __near FDC_SPECIFY_HLT;
extern unsigned char __near FDC_SPECIFY_ND;
extern void FDC_SendParameterByte(int);
void FDC_SendParams_Specify(void)
{
    unsigned char hi, lo;
    hi = FDC_SPECIFY_SRT << 4;
    lo = FDC_SPECIFY_HUT & 15;
    FDC_SendParameterByte(hi | lo);
    hi = FDC_SPECIFY_HLT << 1;
    lo = FDC_SPECIFY_ND & 1;
    FDC_SendParameterByte(hi | lo);
}
