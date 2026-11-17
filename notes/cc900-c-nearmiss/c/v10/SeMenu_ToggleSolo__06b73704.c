/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_18m129c.c (2026-11-16-118-p6-r23)
   sha256 06b73704d0a6ee2b8d0f07d65b5afea068f667cea68d85ddbb07e2cd878a69bd (tar-sha256); compiled at -O3 -Xr
   cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */
extern void SeMenu_SMD_Sec3End(int on);
extern void SeMenu_SetupMenuDisplay_Finalize(unsigned char *solo);
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SeMenu_DrawSoloButton(void);
void SeMenu_ToggleSolo(void)
{
    unsigned char s;
    int on;
    SeMenu_SetupMenuDisplay_Finalize(&s);
    on = 1;
    if (s != 0)
        on = 0;
    SeMenu_SMD_Sec3End(on);
    SeMenu_SetupMenuDisplay(1);
    SeMenu_DrawSoloButton();
}
