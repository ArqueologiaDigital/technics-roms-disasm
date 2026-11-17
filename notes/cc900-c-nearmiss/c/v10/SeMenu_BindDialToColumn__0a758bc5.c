/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_14m129b.c (2026-11-16-100-p6-r19)
   sha256 0a758bc52ebe3ab0507a93d6632a2813c8b65e775a413f6cfc4a2c01fd775d79 (tar-sha256); compiled at -Xr */
extern void SeMenu_PostDialEnable(int on);
extern void SeMenu_PostEditUpDownSet(int which, int col, int flag);
void SeMenu_BindDialToColumn(unsigned char col)
{
    SeMenu_PostDialEnable(1);
    SeMenu_PostEditUpDownSet(0, col, 0);
    SeMenu_PostEditUpDownSet(1, col, 128);
}
