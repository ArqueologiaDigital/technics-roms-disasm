/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/fdc_routines_m270_xr.c (2026-11-16-111-p6-r22-staged)
   sha256 3e9188eed62442c58d0c6969f393a850b7486e4c21c50feb61ec7d3778567f9a (tar-sha256); compiled at -Xr
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
