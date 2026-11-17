/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_14m129a.c (2026-11-16-100-p6-r19)
   sha256 701b50862cea8afdb7d4731ed7801af5090888e61b80a277453a14a39b81a886 (tar-sha256); compiled at -Xr */
extern void SeMenu_PostDialEnable(int on);
extern void SeMenu_PostEditUpDownSet(int which, int col, int flag);
void SeMenu_BindDialToColumn(unsigned char col)
{
    SeMenu_PostDialEnable(1);
    SeMenu_PostEditUpDownSet(0, col, 0);
    SeMenu_PostEditUpDownSet(1, col, 128);
}
