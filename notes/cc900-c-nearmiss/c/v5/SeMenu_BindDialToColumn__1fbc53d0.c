/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/semenu_routines_m129.c (2026-11-16-103-p6-r20-staged)
   sha256 1fbc53d0516228a3363458c280aee2a08d8f12050e182bb7ec35ab7bbf5e93fe (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_PostDialEnable(int on);
extern void SeMenu_PostEditUpDownSet(int which, int col, int flag);
void SeMenu_BindDialToColumn(unsigned char col)
{
    SeMenu_PostDialEnable(1);
    SeMenu_PostEditUpDownSet(0, col, 0);
    SeMenu_PostEditUpDownSet(1, col, 128);
}
