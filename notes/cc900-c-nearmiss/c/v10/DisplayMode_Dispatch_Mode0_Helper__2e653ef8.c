/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_8b.c (2026-11-16-53-p6-r11)
   sha256 2e653ef8b65fbca41cde47c6cf85f0d99977fce6cf00e855ff8dcb59f7554120 (tar-sha256); compiled at -O3 -Xr
   cc900-name: DisplayMode_Disp_Mode0_Helper=DisplayMode_Dispatch_Mode0_Helper
   cc900-name: Scoop_SpecMode_ParamCheckBound=Scoop_SpecialMode_ParamCheckBound */
extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_CURSOR_TRACK;
extern unsigned char __near ram_d54;
extern unsigned char __near ram_d6a;
extern unsigned char __near ram_10fa;
extern unsigned char __near ram_e3e2;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern unsigned char __near ram_8d88;
extern void Scoop_SpecMode_ParamCheckBound(void);
extern void SqStep_SetupCursorTrack(void);
extern void UI_InterruptTitleByIndex(int);
void DisplayMode_Disp_Mode0_Helper(void)
{
    SEQ_TRACK = SEQ_CURSOR_TRACK;
    Scoop_SpecMode_ParamCheckBound();
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
