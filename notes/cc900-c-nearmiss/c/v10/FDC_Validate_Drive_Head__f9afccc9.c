/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_13m270.c (2026-11-16-100-p6-r19)
   sha256 f9afccc92d4f380fc868b037e9ce1ad6786885a26813d1cbe861cf083138ef4a (tar-sha256); compiled at -Xr */
extern unsigned int __near FDC_REQ_HEAD;
extern unsigned char FDC_Set_Status(int);
void FDC_Validate_Drive_Head(void)
{
    if (FDC_REQ_HEAD != 0 && FDC_REQ_HEAD != 1) FDC_Set_Status(0xfe);
}
