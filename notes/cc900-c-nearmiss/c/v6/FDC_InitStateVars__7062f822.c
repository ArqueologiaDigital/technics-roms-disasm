/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/fdc_routines_m0.c (2026-11-16-111-p6-r22-staged)
   sha256 7062f82284640bf0445ada0365e05fba36867ca271e6af639790522ec8bfcb87 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_89b6;
extern unsigned char __near FDC_SPECIFY_SRT;
extern unsigned char __near FDC_SPECIFY_HUT;
extern unsigned char __near FDC_SPECIFY_HLT;
extern unsigned char __near FDC_SPECIFY_ND;
extern unsigned char __near FDC_PARAM_DTL;
extern unsigned char __near FDC_FORMAT_FILL;
extern unsigned char __near ram_8983;
extern unsigned char __near ram_8984;
extern unsigned char __near ram_8985;
extern unsigned char __near ram_8986;
extern unsigned char __near ram_8987;
void FDC_InitStateVars(void)
{
    FDC_SPECIFY_SRT = (ram_89b6 >> 4) & 0xf;
    FDC_PARAM_DTL = 255;
    FDC_FORMAT_FILL = 0;
    FDC_SPECIFY_HUT = 15;
    FDC_SPECIFY_HLT = 1;
    ram_8984 = 0;
    ram_8983 = 0;
    ram_8985 = 0;
    ram_8986 = 0;
    ram_8987 = 0;
    FDC_SPECIFY_ND = 0;
}
