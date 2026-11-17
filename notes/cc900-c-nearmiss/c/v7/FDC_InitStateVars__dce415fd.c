/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/fdc_routines_m0.c (2026-11-16-111-p6-r22-staged)
   sha256 dce415fda3467180aee7114eccc3f0bbdfe84ac42a9c17c7f2f29be4fc8c6f37 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_89d2;
extern unsigned char __near FDC_SPECIFY_SRT;
extern unsigned char __near FDC_SPECIFY_HUT;
extern unsigned char __near FDC_SPECIFY_HLT;
extern unsigned char __near FDC_SPECIFY_ND;
extern unsigned char __near FDC_PARAM_DTL;
extern unsigned char __near FDC_FORMAT_FILL;
extern unsigned char __near ram_899f;
extern unsigned char __near ram_89a0;
extern unsigned char __near ram_89a1;
extern unsigned char __near ram_89a2;
extern unsigned char __near ram_89a3;
void FDC_InitStateVars(void)
{
    FDC_SPECIFY_SRT = (ram_89d2 >> 4) & 0xf;
    FDC_PARAM_DTL = 255;
    FDC_FORMAT_FILL = 0;
    FDC_SPECIFY_HUT = 15;
    FDC_SPECIFY_HLT = 1;
    ram_89a0 = 0;
    ram_899f = 0;
    ram_89a1 = 0;
    ram_89a2 = 0;
    ram_89a3 = 0;
    FDC_SPECIFY_ND = 0;
}
