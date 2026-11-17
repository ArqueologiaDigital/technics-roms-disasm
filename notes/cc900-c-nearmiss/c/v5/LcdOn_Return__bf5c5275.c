/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/ui_widget_defs_xr.c (2026-11-16-55-p6-r10)
   sha256 bf5c527558a6dc969bae7331bc98d89351478a3a1096f85a9106789feffb6585 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned int ram_30464;
void LcdOn_Return(void)
{
    VGA_ScreenBlank();
    ram_30464 = 0;
}
