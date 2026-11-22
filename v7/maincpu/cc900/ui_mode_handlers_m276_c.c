/* Functions of ui/ui_mode_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: EffectMode_InitSwbWr_DiagMode EffectMode_RestoreSwbWr_NormalMode EffectMode_RunDiagSequence EffectMode_SetAllLEDs LED_SetAll_WithBlank */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near ram_8ce4;
extern unsigned char __near ram_8ce6;
extern unsigned char __near ram_e318;
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
        if (ram_8ce6 != 2) {
            f = ram_8ce4;
            if (f & 1) {
                if (!(f & 0x10)) {
                    ram_8ce4 = f | 0x10;
                    if (ram_8ce6 != 1) {
                        ram_8ce6 = 1;
                        EffectMode_InitSwbWr_DiagMode();
                        EffectMode_SetAllLEDs();
                    }
                }
            } else {
                if (f & 0x10) {
                    ram_8ce4 = f & ~0x10;
                    if (ram_8ce6 != 0) {
                        ram_8ce6 = 0;
                        EffectMode_RestoreSwbWr_NormalMode();
                        LED_SetAll_WithBlank();
                        ram_e318 = 16;
                    }
                }
            }
        } else {
            ram_8ce6 = 0;
            LED_SetAll_WithBlank();
            EffectMode_RestoreSwbWr_NormalMode();
        }
    }
    if (CURRENT_TITLE == 248) EffectMode_HandleTimerEvents();
    if (CURRENT_TITLE == 247) EffectMode_ModeChangeTransition();
    if (CURRENT_TITLE == 251) EffectMode_RunDiagSequence();
}
