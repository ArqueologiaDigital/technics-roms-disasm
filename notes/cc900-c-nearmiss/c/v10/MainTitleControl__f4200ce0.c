/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_22r2m270a.c (2026-11-21-21-p6-r66)
   sha256 f4200ce0577e6e8f77c80de57a92e5339a982ea2a2479b5c0e14410b2662d66a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define EVT_CHANGE_MODE          0x1c00014L
#define EVT_CHANGE_TITLE         0x1c00015L
#define EVT_INTERRUPT_TITLE      0x1c00016L
#define EVT_RETURN_TITLE         0x1c00028L
#define EVT_ACTIVATE_STATE       0x1c00013L
#define EVT_OTHER_PART_LED       0x1e000abL
#define EVT_SET_TITLE_FLAG       0x1e000baL
#define EVT_MAIN_LOOP_COUNT      0x1e000bbL
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near PREVIOUS_MODE;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near PREVIOUS_TITLE;
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near ACTIVE_TITLE_PREVIOUS;
extern unsigned char __near ram_8f5c;
extern long PANEL_SW_HELD_BOTH;
extern long PANEL_SW_HELD_DOWN;
extern long PANEL_SW_HELD_UP;
extern unsigned int TITLE_FLAGS_LATCHED;
extern unsigned int TITLE_FLAGS_PENDING;
extern unsigned int TITLE_FLAGS_DELAY;
extern unsigned int OTHER_PART_LED_PENDING;
extern unsigned int OTHER_PART_LED_DELAY;
extern void CtrlPanel_SetIndicatorBit(unsigned int);
extern void AudioMode_ResetVoiceState(void);
long MainTitleControl(long obj, long evt, long param)
{
	switch (evt) {
	case EVT_CHANGE_MODE:
		PREVIOUS_MODE = CURRENT_MODE;
		CURRENT_MODE = (unsigned char)(param & 0xffff);
		CtrlPanel_SetIndicatorBit(0x48);
		PANEL_SW_HELD_BOTH = 0;
		PANEL_SW_HELD_DOWN = 0;
		PANEL_SW_HELD_UP = 0;
		break;
	case EVT_CHANGE_TITLE:
		PREVIOUS_TITLE = CURRENT_TITLE;
		ACTIVE_TITLE_PREVIOUS = ACTIVE_TITLE;
		CURRENT_TITLE = (unsigned char)(param & 0xffff);
		ACTIVE_TITLE = (unsigned char)(param & 0xffff);
		CtrlPanel_SetIndicatorBit(0x61);
		PANEL_SW_HELD_BOTH = 0;
		PANEL_SW_HELD_DOWN = 0;
		PANEL_SW_HELD_UP = 0;
		AudioMode_ResetVoiceState();
		break;
	case EVT_INTERRUPT_TITLE:
	case EVT_RETURN_TITLE:
		ACTIVE_TITLE_PREVIOUS = ACTIVE_TITLE;
		ACTIVE_TITLE = (unsigned char)(param & 0xffff);
		CtrlPanel_SetIndicatorBit(0x61);
		PANEL_SW_HELD_BOTH = 0;
		PANEL_SW_HELD_DOWN = 0;
		PANEL_SW_HELD_UP = 0;
		AudioMode_ResetVoiceState();
		break;
	case EVT_ACTIVATE_STATE:
		if (param == 8) {
			if (ACTIVE_TITLE == CURRENT_TITLE) PREVIOUS_TITLE = CURRENT_TITLE;
			ACTIVE_TITLE_PREVIOUS = ACTIVE_TITLE;
			PREVIOUS_MODE = CURRENT_MODE;
		}
		break;
	case EVT_OTHER_PART_LED:
		OTHER_PART_LED_PENDING = (unsigned int)param;
		OTHER_PART_LED_DELAY = 10;
		break;
	case EVT_SET_TITLE_FLAG:
		TITLE_FLAGS_PENDING = (unsigned int)param;
		TITLE_FLAGS_DELAY = 10;
		break;
	case EVT_MAIN_LOOP_COUNT:
		if (TITLE_FLAGS_DELAY != 0 && --TITLE_FLAGS_DELAY == 0) TITLE_FLAGS_LATCHED = TITLE_FLAGS_PENDING;
		if (OTHER_PART_LED_DELAY != 0 && --OTHER_PART_LED_DELAY == 0) {
			if (OTHER_PART_LED_PENDING != 0) ram_8f5c |= 1;
			else ram_8f5c &= ~1;
			CtrlPanel_SetIndicatorBit(0x60);
		}
		break;
	}
	return 0;
}
