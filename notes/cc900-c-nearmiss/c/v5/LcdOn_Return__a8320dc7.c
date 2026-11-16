/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/ui_widget_defs_m273_xr.c (2026-11-16-68-p6-r12)
   sha256 a8320dc78f237dcc2f0b82e10f8dab2bdb5cfdc6236ca2682a0f47417bf62986 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned int ram_30464;
extern void VGA_ScreenBlank(void);
void LcdOn_Return(void)
{
    VGA_ScreenBlank();
    ram_30464 = 0;
}
