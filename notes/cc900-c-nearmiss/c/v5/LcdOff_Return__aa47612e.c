/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/ui_widget_defs_m0_xr.c (2026-11-16-68-p6-r12)
   sha256 aa47612e350ba33ff8869fbcdfd03891f28f9dc5caee620dcee0972b287b1849 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned int ram_30464;
extern void VGA_ScreenBlank(void);
void LcdOff_Return(void)
{
    if (ram_30464 != 0)
        VGA_ScreenBlank();
}
