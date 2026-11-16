/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_7a.c (2026-11-16-45-p6-r9)
   sha256 6921ff2671991f57b87626d5ba965b790b65748d46a195de5a24a7e36b18379b (tar-sha256); compiled at -O3 -Xr */
extern unsigned int ram_30464;
extern void VGA_ScreenBlank(void);
void LcdOff_Return(void)
{
    if (ram_30464 == 0)
        return;
    VGA_ScreenBlank();
}
