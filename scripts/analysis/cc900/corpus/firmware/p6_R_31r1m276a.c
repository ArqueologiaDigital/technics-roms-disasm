/* Probe round 31r1, helper R, form a: ui/ui_mode_handlers.s EffectMode_CheckAndDispatch.  On the diagnostic
   title (251) follow bit 0 of ram_8d80 into the diagnostic mode (ram_8d82), then run the title's handler. */
/* cc900-module: EffectMode_InitSwbWr_DiagMode EffectMode_RestoreSwbWr_NormalMode EffectMode_RunDiagSequence EffectMode_SetAllLEDs LED_SetAll_WithBlank */

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
extern void EffectMode_CheckAndDispatch(void);

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
