/* Phase 6, lane_p6 helper D, round 18, module 280 (v10 audio/audio_control_engine.s), form a, after run 123:
   - ExtData_SetTempoIfChanged: at -O3 round 17 form a differed only in loading the value before the two addresses
     and keeping it in L (the ROM: after them, in E): the value is read from EXTDATA_VALUE at each use (one common
     subexpression) instead of a local.
   - ExtData_Voice_MixedHandler: an int-returning ExtData_ApplyTransposeEvent kept its call at -O3; the ROM also
     calls CtrlPanel_SetIndicatorBit and returns, so it is declared int too.  Cases written 0 then 2 (the ROM
     compares 2 first).  Form b (p6_D_18m280b.c): the || test in SetTempo, and a leading `default: return;` with
     case 2 written first in the switch. */
/* cc900-module: ExtData_ApplyTransposeEvent ExtData_StepTlvField ExtData_ToggleTlvBits SndParam_WriteLookupAndStore SwbtWr_FlushAndAppendParams */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern void SwbtWr_FlushAndAppendParams(void);
extern void ExtData_ToggleTlvBits(unsigned int);
extern void ExtData_StepTlvField(unsigned int, unsigned int);
extern int ExtData_ApplyTransposeEvent(void);
extern void SndParam_WriteLookupAndStore(void);
extern void SeqTimer_UpdateTempoReg(void);
extern int CtrlPanel_SetIndicatorBit(unsigned int);

extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near MIDI_MSG_DATA1;
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near ram_9153;
extern unsigned char __near ram_9154;
extern unsigned char __near ram_9155;
extern unsigned char __near ram_c5c8;
extern unsigned char __near ram_8f58;
extern unsigned char __near PANEL_PLAY_SETTINGS[];
extern unsigned char SplitPoint_LedMaskByPreset[];

void ExtData_SetTempoIfChanged(void)
{
	unsigned char *s;

	s = PANEL_STYLE;
	if (s[8] == EXTDATA_VALUE && s[9] == EXTDATA_MASK) return;
	s[8] = EXTDATA_VALUE;
	s[9] = EXTDATA_MASK;
	MIDI_MSG_DATA2 = s[8];
	MIDI_MSG_DATA3 = 255;
	SwbtWr_FlushAndAppendParams();
	MIDI_MSG_DATA1 = 9;
	MIDI_MSG_DATA2 = s[9];
	MIDI_MSG_DATA3 = 1;
	SwbtWr_FlushAndAppendParams();
	SeqTimer_UpdateTempoReg();
}

void ExtData_Voice_MixedHandler(void)
{
	SndParam_WriteLookupAndStore();
	switch (EXTDATA_TLV_OFFSET) {
	case 0:
		ExtData_ToggleTlvBits(4);
		SwbtWr_FlushAndAppendParams();
		ram_9153 = 1;
		ram_9154 = 4;
		ram_9155 = 0;
		ExtData_StepTlvField(1, 3);
		SwbtWr_FlushAndAppendParams();
		if (ram_c5c8 != 255) break;
		if ((EXTDATA_VALUE & EXTDATA_MASK) & 1) ram_8f58 = SplitPoint_LedMaskByPreset[PANEL_PLAY_SETTINGS[0] & 3];
		else ram_8f58 = 0;
		CtrlPanel_SetIndicatorBit(69);
		break;
	case 2:
		ExtData_ApplyTransposeEvent();
		break;
	}
}
