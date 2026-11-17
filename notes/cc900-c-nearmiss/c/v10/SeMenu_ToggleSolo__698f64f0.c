/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_17m129a.c (2026-11-16-107-p6-r21)
   sha256 698f64f0f1ea99498d87379fdf4d3cc047b1f0daa825dc1ac0fab1e8f0e65b0e (tar-sha256); compiled at -O3 -Xr
   cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */
extern void SeMenu_SMD_Sec3End(int on);
extern void SeMenu_SetupMenuDisplay_Finalize(unsigned char *solo);
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SeMenu_DrawSoloButton(void);
void SeMenu_ToggleSolo(void)
{
    unsigned char s;
    SeMenu_SetupMenuDisplay_Finalize(&s);
    if (s != 0)
        SeMenu_SMD_Sec3End(0);
    else
        SeMenu_SMD_Sec3End(1);
    SeMenu_SetupMenuDisplay(1);
    SeMenu_DrawSoloButton();
}
