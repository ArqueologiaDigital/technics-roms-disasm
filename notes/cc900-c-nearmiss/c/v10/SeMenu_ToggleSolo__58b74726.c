/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_18m129b.c (2026-11-16-118-p6-r23)
   sha256 58b7472602523e16bf72608ad52e7959eeb087cbe9749bc3c3639c63a7f82c25 (tar-sha256); compiled at -Xr
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
    if (s != 0)
        on = 0;
    else
        on = 1;
    SeMenu_SMD_Sec3End(on);
    SeMenu_SetupMenuDisplay(1);
    SeMenu_DrawSoloButton();
}
