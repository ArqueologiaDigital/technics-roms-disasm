/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_17m129b.c (2026-11-16-107-p6-r21)
   sha256 41cc8106ac2042a106a57c77c689c80099e3c1a76c55fe5a5fca2be6397f0f3d (tar-sha256); compiled at -Xr
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
