/* lane_p6 helper B, round 22r2, form a: module 270 (ui/ui_control_panel.s with its include audio/sound_navigation.s),
   from roots23_B's pooled stretch at f99084 (MainGetPmemName itself is hand assembly: pushw_erp / ldfr_berp).
   MainTrSwControl (f99148), MainPmanControl (f99177, its six LSW cases through MainPmanControl_CaseTable based at
   the first case body, MainPmanCtrl_DispatchTable; EVT_PART_SELECT_PUT compared before the table), MainTitleControl
   (f992f5, a compare chain of eight events; bodies in source order, compares in reverse source order).
   Form b: MainTitleControl's id (param & 0xffff) and CURRENT_TITLE in function-scope locals; MainPmanControl's
   record pointer s and copy q at function scope (only `old` in block scope).  MainTrSwControl as in form a.
   cc900-options: -O3 -Xr
*/
/* cc900-data: MainPmanControl 1 = MainPmanControl_CaseTable */

#define EVT_CHANGE_MODE          0x1c00014L
#define EVT_CHANGE_TITLE         0x1c00015L
#define EVT_INTERRUPT_TITLE      0x1c00016L
#define EVT_RETURN_TITLE         0x1c00028L
#define EVT_ACTIVATE_STATE       0x1c00013L
#define EVT_OTHER_PART_LED       0x1e000abL
#define EVT_SET_TITLE_FLAG       0x1e000baL
#define EVT_MAIN_LOOP_COUNT      0x1e000bbL
#define EVT_LSW_DATA             0x1c0001cL
#define EVT_AUTO_FREE            0x1e00023L
#define EVT_LSW_PUT              0x1e00057L
#define EVT_LSW_ADD              0x1e00058L
#define EVT_LSW_GET              0x1e00059L
#define EVT_LSW_PART_PUT         0x1e0005aL
#define EVT_LSW_PART_ADD         0x1e0005bL
#define EVT_LSW_PART_GET         0x1e0005cL
#define EVT_PART_SELECT_PUT      0x1e000a0L
#define EVT_REQUEST_TRACK_SWITCH 0x1e00092L
#define EVT_TOGGLE_TRACK_SWITCH  0x1e00093L

struct lsw { unsigned long id; int value; int out; long spare; };

extern unsigned char __near CURRENT_MODE;
extern unsigned char __near PREVIOUS_MODE;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near PREVIOUS_TITLE;
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near ACTIVE_TITLE_PREVIOUS;
extern unsigned char __near PART_SELECT;
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
extern long ApPostEvent(long, long, void *);
extern void *__cdecl Malloc(unsigned int);
extern void SoundParam_NotifyChange(long, int, int);
extern int SndParam_LookupByKey(unsigned long, int, int);
extern int SndParam_LookupReadOnly(long);
extern void SndParam_NotifyAndReturn(long, long, int, int);
extern void SndParam_WrapNotify2(long, long, int, int);
extern int SndParam_LookupViaEncode(long, long);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);
extern void SeqVoice_DispatchEventToHandler(unsigned int);
extern void SeqVoice_ComputeStatusFlags(unsigned int);
extern void AppEvent_HandleChannelEvent(unsigned int);

long MainTrSwControl(long obj, long evt, long param);
long MainPmanControl(long obj, long evt, unsigned long param);
long MainTitleControl(long obj, long evt, long param);

long MainTrSwControl(long obj, long evt, long param)
{
	switch (evt) {
	case EVT_REQUEST_TRACK_SWITCH:
		SeqVoice_DispatchEventToHandler((unsigned char)param);
		SeqVoice_ComputeStatusFlags((unsigned char)param);
		break;
	case EVT_TOGGLE_TRACK_SWITCH:
		AppEvent_HandleChannelEvent((unsigned char)param);
		break;
	}
	return 0;
}

long MainPmanControl(long obj, long evt, unsigned long param)
{
	struct lsw *s;
	struct lsw *q;
	switch (evt) {
	case EVT_LSW_PUT:
		s = (struct lsw *)param;
		SoundParam_NotifyChange(s->id, s->value, s->out);
		break;
	case EVT_LSW_ADD:
		s = (struct lsw *)param;
		SndParam_LookupByKey(s->id, s->value, s->out);
		break;
	case EVT_LSW_GET:
		s = (struct lsw *)param;
		s->value = SndParam_LookupReadOnly(s->id);
		q = Malloc(12);
		*q = *s;
		ApPostEvent(-1L, EVT_LSW_DATA, q);
		ApPostEvent(-1L, EVT_AUTO_FREE, q);
		break;
	case EVT_LSW_PART_PUT:
		s = (struct lsw *)param;
		SndParam_NotifyAndReturn((unsigned int)(s->id >> 16), s->id, s->value, s->out);
		break;
	case EVT_LSW_PART_ADD:
		s = (struct lsw *)param;
		SndParam_WrapNotify2((unsigned int)(s->id >> 16), s->id, s->value, s->out);
		break;
	case EVT_LSW_PART_GET:
		s = (struct lsw *)param;
		s->value = SndParam_LookupViaEncode((unsigned int)(s->id >> 16), s->id);
		q = Malloc(12);
		*q = *s;
		ApPostEvent(-1L, EVT_LSW_DATA, q);
		ApPostEvent(-1L, EVT_AUTO_FREE, q);
		break;
	case EVT_PART_SELECT_PUT: {
		unsigned char old = PART_SELECT;
		if (param < 0x10 || param == 0x15 || param == 0x16) {
			PART_SELECT = (unsigned char)param;
		} else {
			unsigned char v = SndParam_LookupReadOnly(0x4100L);
			if (v == 1 || v == 5) PART_SELECT = 1;
			else PART_SELECT = 0;
		}
		if (PART_SELECT != old) AddswbWr(0x90, 0x10, PART_SELECT, 0xff);
		break;
	}
	}
	return 0;
}

long MainTitleControl(long obj, long evt, long param)
{
	long id = param & 0xffff;
	unsigned char t;
	switch (evt) {
	case EVT_CHANGE_MODE:
		PREVIOUS_MODE = CURRENT_MODE;
		CURRENT_MODE = (unsigned char)id;
		CtrlPanel_SetIndicatorBit(0x48);
		PANEL_SW_HELD_BOTH = 0;
		PANEL_SW_HELD_DOWN = 0;
		PANEL_SW_HELD_UP = 0;
		break;
	case EVT_CHANGE_TITLE:
		t = CURRENT_TITLE;
		PREVIOUS_TITLE = t;
		ACTIVE_TITLE_PREVIOUS = ACTIVE_TITLE;
		CURRENT_TITLE = (unsigned char)id;
		ACTIVE_TITLE = (unsigned char)id;
		CtrlPanel_SetIndicatorBit(0x61);
		PANEL_SW_HELD_BOTH = 0;
		PANEL_SW_HELD_DOWN = 0;
		PANEL_SW_HELD_UP = 0;
		AudioMode_ResetVoiceState();
		break;
	case EVT_INTERRUPT_TITLE:
	case EVT_RETURN_TITLE:
		ACTIVE_TITLE_PREVIOUS = ACTIVE_TITLE;
		ACTIVE_TITLE = (unsigned char)id;
		CtrlPanel_SetIndicatorBit(0x61);
		PANEL_SW_HELD_BOTH = 0;
		PANEL_SW_HELD_DOWN = 0;
		PANEL_SW_HELD_UP = 0;
		AudioMode_ResetVoiceState();
		break;
	case EVT_ACTIVATE_STATE:
		if (param == 8) {
			t = CURRENT_TITLE;
			if (ACTIVE_TITLE == t) PREVIOUS_TITLE = t;
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
