/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_6a.c (2026-11-16-45-p6-r9)
   sha256 0aba4f340e3599d581d783318d3005acf17c6d64d605c3d6dbff3c5f63208f2d (tar-sha256); compiled at -O3 -Xr
   cc900-name: DisplayMode_Disp_Mode0_Helper=DisplayMode_Dispatch_Mode0_Helper */
extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_CURSOR_TRACK;
extern unsigned char __near ram_d54;
extern unsigned char __near ram_d6a;
extern unsigned char __near ram_10fa;
extern unsigned char __near ram_e3e2;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern unsigned char __near ram_8d88;
extern void Scoop_SpecialMode_ParamCheckBound(void);
extern void SqStep_SetupCursorTrack(void);
extern void UI_InterruptTitleByIndex(int);
void DisplayMode_Disp_Mode0_Helper(void)
{
    SEQ_TRACK = SEQ_CURSOR_TRACK;
    Scoop_SpecialMode_ParamCheckBound();
    ram_d54 &= ~0x80;
    ram_d6a = 0;
    ram_10fa = 1;
    SqStep_SetupCursorTrack();
    ram_10fa = 0;
    ram_e3e2 &= 0x6f;
    GLOBAL_ERROR_CODE = 35;
    UI_InterruptTitleByIndex(0xee);
    ram_8d88 |= 1;
}
