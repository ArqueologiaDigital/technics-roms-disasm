/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_13m270.c (2026-11-16-100-p6-r19)
   sha256 f9afccc92d4f380fc868b037e9ce1ad6786885a26813d1cbe861cf083138ef4a (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ram_8a6e;
extern unsigned char __near FDC_SPECIFY_SRT;
extern unsigned char __near FDC_SPECIFY_HUT;
extern unsigned char __near FDC_SPECIFY_HLT;
extern unsigned char __near FDC_SPECIFY_ND;
extern unsigned char __near FDC_PARAM_DTL;
extern unsigned char __near FDC_FORMAT_FILL;
extern unsigned char __near ram_8a3b;
extern unsigned char __near ram_8a3c;
extern unsigned char __near ram_8a3d;
extern unsigned char __near ram_8a3e;
extern unsigned char __near ram_8a3f;
void FDC_InitStateVars(void)
{
    FDC_SPECIFY_SRT = (ram_8a6e >> 4) & 0xf;
    FDC_PARAM_DTL = 255;
    FDC_FORMAT_FILL = 0;
    FDC_SPECIFY_HUT = 15;
    FDC_SPECIFY_HLT = 1;
    ram_8a3c = 0;
    ram_8a3b = 0;
    ram_8a3d = 0;
    ram_8a3e = 0;
    ram_8a3f = 0;
    FDC_SPECIFY_ND = 0;
}
