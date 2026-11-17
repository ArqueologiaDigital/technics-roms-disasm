/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_12m270a.c (2026-11-16-92-p6-r18)
   sha256 9f8546f017e7acefbd0e8b9558081c734985c189b6048ac4ec17747fd0bfa6f0 (tar-sha256); compiled at -Xr */
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
