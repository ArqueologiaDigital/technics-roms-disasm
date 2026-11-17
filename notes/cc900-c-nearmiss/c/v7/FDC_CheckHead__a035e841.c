/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/fdc_routines_m270_xr.c (2026-11-16-111-p6-r22-staged)
   sha256 a035e841d7293846b48f030e11358e6f4ccc7537fd96ee1103796cf870c21472 (tar-sha256); compiled at -Xr
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
