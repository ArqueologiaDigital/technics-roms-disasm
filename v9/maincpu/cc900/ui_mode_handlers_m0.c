/* Functions of ui/ui_mode_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

#define EVT_SHOW                      0x1c00001L
#define NAKA_VIEW_TEST51              0xf80006L
#define NAKA_VIEW_TEST52              0xf80008L
#define NAKA_VIEW_TEST53              0xf8000aL
#define NAKA_VIEW_TEST54              0xf8000cL
#define NAKA_VIEW_TEST55              0xf8000eL
#define NAKA_VIEW_TEST56              0xf80010L
extern long ApPostEvent(long, long, long);
extern unsigned char __near DIAG_ANIM_STEP;
extern int CtrlPanel_GetSelectionState(void);

void EffectMode_HandleTimerEvents(void)
{
    if (CtrlPanel_GetSelectionState()) return;
    switch (DIAG_ANIM_STEP) {
    case 0:
        ApPostEvent(NAKA_VIEW_TEST54, EVT_SHOW, 0);
        ++DIAG_ANIM_STEP;
        ++DIAG_ANIM_STEP;
        break;
    case 30:
        ApPostEvent(NAKA_VIEW_TEST55, EVT_SHOW, 0);
        ++DIAG_ANIM_STEP;
        ++DIAG_ANIM_STEP;
        break;
    case 60:
        ApPostEvent(NAKA_VIEW_TEST56, EVT_SHOW, 0);
        ++DIAG_ANIM_STEP;
        ++DIAG_ANIM_STEP;
        break;
    case 90:
        ApPostEvent(NAKA_VIEW_TEST51, EVT_SHOW, 0);
        ++DIAG_ANIM_STEP;
        ++DIAG_ANIM_STEP;
        break;
    case 120:
        ApPostEvent(NAKA_VIEW_TEST52, EVT_SHOW, 0);
        ++DIAG_ANIM_STEP;
        ++DIAG_ANIM_STEP;
        break;
    case 150:
        ApPostEvent(NAKA_VIEW_TEST53, EVT_SHOW, 0);
        DIAG_ANIM_STEP = 220;
        break;
    default:
        ++DIAG_ANIM_STEP;
        ++DIAG_ANIM_STEP;
        break;
    }
}

/* cc900-module: EffectMode_MidiSetLEDs */
extern unsigned char __near ram_8d6c[];
extern int PanelInput_ReadRxRecord(unsigned char *rec);
extern void EffectMode_MidiSetLEDs(unsigned char *rec);
extern void EffectMode_MidiParseLoop(void);

void EffectMode_MidiParseLoop(void)
{
	unsigned char *p;

	p = ram_8d6c;
	while (PanelInput_ReadRxRecord(p) != -1)
		EffectMode_MidiSetLEDs(p);
}
