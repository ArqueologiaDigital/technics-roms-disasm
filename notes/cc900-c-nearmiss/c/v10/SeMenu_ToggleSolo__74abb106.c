/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/semenu_routines_m129.c (2026-11-16-122-p6-r24-staged)
   sha256 74abb106c8d3e45165064f2d94575287aca8746d5f160c5d2a881194b780b282 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
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
