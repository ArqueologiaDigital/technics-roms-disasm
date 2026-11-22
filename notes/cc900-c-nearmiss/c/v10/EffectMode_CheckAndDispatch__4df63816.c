/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_31r1m276a.c (2026-11-22-15-p6-r82)
   sha256 4df63816152846f38414d95db9bbbfc9a3374562e805ee58b6263f13d37b2d3c (tar-sha256); compiled at -Xr */
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
    unsigned char f;

    if (CURRENT_TITLE == 251) {
        if (ram_8d82 != 2) {
            f = ram_8d80;
            if (f & 1) {
                if (!(f & 0x10)) {
                    ram_8d80 = f | 0x10;
                    if (ram_8d82 != 1) {
                        ram_8d82 = 1;
                        EffectMode_InitSwbWr_DiagMode();
                        EffectMode_SetAllLEDs();
                    }
                }
            } else {
                if (f & 0x10) {
                    ram_8d80 = f & ~0x10;
                    if (ram_8d82 != 0) {
                        ram_8d82 = 0;
                        EffectMode_RestoreSwbWr_NormalMode();
                        LED_SetAll_WithBlank();
                        ram_e3de = 16;
                    }
                }
            }
        } else {
            ram_8d82 = 0;
            LED_SetAll_WithBlank();
            EffectMode_RestoreSwbWr_NormalMode();
        }
    }
    if (CURRENT_TITLE == 248) EffectMode_HandleTimerEvents();
    if (CURRENT_TITLE == 247) EffectMode_ModeChangeTransition();
    if (CURRENT_TITLE == 251) EffectMode_RunDiagSequence();
}
