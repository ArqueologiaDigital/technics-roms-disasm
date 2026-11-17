/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/semenu_routines_m129.c (2026-11-16-111-p6-r22-staged)
   sha256 e8e54ecf7f562beef010be3aa4cf15cfc9811abb7ea644b41fbd0a9d48c045ad (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_PostDialEnable(int on);
extern void SeMenu_PostEditUpDownSet(int which, int col, int flag);
void SeMenu_BindDialToColumn(unsigned char col)
{
    SeMenu_PostDialEnable(1);
    SeMenu_PostEditUpDownSet(0, col, 0);
    SeMenu_PostEditUpDownSet(1, col, 128);
}
