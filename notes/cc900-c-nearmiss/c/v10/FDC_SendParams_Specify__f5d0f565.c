/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_12m270b.c (2026-11-16-92-p6-r18)
   sha256 f5d0f56570c157c33efe566fd50ad73cf094fa0f67d3b4cd89567ae4b3895e1b (tar-sha256); compiled at -Xr */
extern unsigned char __near FDC_SPECIFY_SRT;
extern unsigned char __near FDC_SPECIFY_HUT;
extern unsigned char __near FDC_SPECIFY_HLT;
extern unsigned char __near FDC_SPECIFY_ND;
extern void FDC_SendParameterByte(int);
void FDC_SendParams_Specify(void)
{
    unsigned char hi;
    hi = FDC_SPECIFY_SRT << 4;
    FDC_SendParameterByte(hi | (FDC_SPECIFY_HUT & 15));
    hi = FDC_SPECIFY_HLT << 1;
    FDC_SendParameterByte(hi | (FDC_SPECIFY_ND & 1));
}
