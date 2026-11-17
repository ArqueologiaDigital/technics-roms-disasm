/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/fdc_routines_m270_xr.c (2026-11-16-111-p6-r22-staged)
   sha256 3e9188eed62442c58d0c6969f393a850b7486e4c21c50feb61ec7d3778567f9a (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char FDC_Set_Status(int);
extern unsigned int __near FDC_REQ_HEAD;
extern unsigned char __near FDC_PARAM_H;
extern unsigned char __near FDC_HEAD;
void FDC_CheckHead(void)
{
    FDC_HEAD = FDC_PARAM_H = FDC_REQ_HEAD;
    if (FDC_HEAD != 0 && FDC_HEAD != 1) FDC_Set_Status(0xfe);
}
