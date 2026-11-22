/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_31r1m276b.c (2026-11-22-15-p6-r82)
   sha256 a79c567ce73f01d1257dbed20aa5ba9ba96f33277eb1be0d363fa02fa59efdba (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near ram_8d80;
extern unsigned char __near ram_8d82;
extern unsigned char __near ram_e3de;
extern void EffectMode_InitSwbWr_DiagMode(void);
extern void EffectMode_SetAllLEDs(void);
extern void EffectMode_RestoreSwbWr_NormalMode(void);
extern void LED_SetAll_WithBlank(void);
extern void EffectMode_HandleTimerEvents(void);
extern void EffectMode_ModeChangeTransition(void);
extern void EffectMode_RunDiagSequence(void);
void EffectMode_CheckAndDispatch(void)
{
    if (CURRENT_TITLE == 251) {
        if (ram_8d82 == 2) {
            ram_8d82 = 0;
            LED_SetAll_WithBlank();
            EffectMode_RestoreSwbWr_NormalMode();
        } else if (ram_8d80 & 1) {
            if (!(ram_8d80 & 0x10)) {
                ram_8d80 |= 0x10;
                if (ram_8d82 != 1) {
                    ram_8d82 = 1;
                    EffectMode_InitSwbWr_DiagMode();
                    EffectMode_SetAllLEDs();
                }
            }
        } else if (ram_8d80 & 0x10) {
            ram_8d80 &= ~0x10;
            if (ram_8d82 != 0) {
                ram_8d82 = 0;
                EffectMode_RestoreSwbWr_NormalMode();
                LED_SetAll_WithBlank();
                ram_e3de = 16;
            }
        }
    }
    if (CURRENT_TITLE == 248) EffectMode_HandleTimerEvents();
    if (CURRENT_TITLE == 247) EffectMode_ModeChangeTransition();
    if (CURRENT_TITLE == 251) EffectMode_RunDiagSequence();
}
