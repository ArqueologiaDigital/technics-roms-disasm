/* Phase 6, lane_p6 helper D, round 17, module 280 (v10 audio/audio_control_engine.s), form a, after run 118:
   ExtData_SetTempoIfChanged with the tempo bytes read as s[8] / s[9] of a record pointer (no byte pointers: the
   ROM's two lda's should be -O3 common subexpressions), and ExtData_Voice_MixedHandler with
   ExtData_ApplyTransposeEvent declared as returning int: the ROM calls it and returns (no tail jump), which a void
   callee does not give.  Run 118 showed V4.23 compares switch cases last-first; the ROM compares 2 before 0, so
   form a writes case 0 first; form b (p6_D_17m280b.c) writes case 2 first and reads the tempo bytes from
   PANEL_STYLE directly. */
/* cc900-module: ExtData_ApplyTransposeEvent ExtData_StepTlvField ExtData_ToggleTlvBits SndParam_WriteLookupAndStore SwbtWr_FlushAndAppendParams */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern void SwbtWr_FlushAndAppendParams(void);
extern void ExtData_ToggleTlvBits(unsigned int);
extern void ExtData_StepTlvField(unsigned int, unsigned int);
extern int ExtData_ApplyTransposeEvent(void);
extern void SndParam_WriteLookupAndStore(void);
extern void SeqTimer_UpdateTempoReg(void);
extern void CtrlPanel_SetIndicatorBit(unsigned int);

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
	unsigned char v;

	s = PANEL_STYLE;
	v = EXTDATA_VALUE;
	if (s[8] == v && s[9] == EXTDATA_MASK) return;
	s[8] = v;
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
