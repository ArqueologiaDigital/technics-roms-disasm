/* Phase 6, lane_p6 helper D, round 16, module 280 (v10 audio/audio_control_engine.s), form a (poolmm_D):
   ExtData_SetTempoIfChanged (record 0x48's tempo bytes +8 / +9, moved memory to memory from the __near cells),
   ExtData_ToggleReverbIllusionOnOff (two calls, the last a tail jump) and ExtData_Voice_MixedHandler (offset 2 or
   0 of the event, a switch: the ROM tests 2 first and leaves on any other offset).  Form b (p6_D_16m280b.c) writes
   the tempo bytes through the record pointer only and the handler as if / return. */
/* cc900-module: ExtData_ApplyTransposeEvent ExtData_StepTlvField ExtData_ToggleTlvBits SndParam_WriteLookupAndStore SwbtWr_FlushAndAppendParams */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern void SwbtWr_FlushAndAppendParams(void);
extern void ExtData_ToggleTlvBits(unsigned int);
extern void ExtData_StepTlvField(unsigned int, unsigned int);
extern void ExtData_ApplyTransposeEvent(void);
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
	unsigned char *s, *p, *q;
	unsigned char v;

	s = PANEL_STYLE;
	p = s + 8;
	q = s + 9;
	v = EXTDATA_VALUE;
	if (*p == v && *q == EXTDATA_MASK) return;
	*p = v;
	*q = EXTDATA_MASK;
	MIDI_MSG_DATA2 = *p;
	MIDI_MSG_DATA3 = 255;
	SwbtWr_FlushAndAppendParams();
	MIDI_MSG_DATA1 = 9;
	MIDI_MSG_DATA2 = s[9];
	MIDI_MSG_DATA3 = 1;
	SwbtWr_FlushAndAppendParams();
	SeqTimer_UpdateTempoReg();
}

void ExtData_ToggleReverbIllusionOnOff(void)
{
	ExtData_ToggleTlvBits(192);
	SwbtWr_FlushAndAppendParams();
}

void ExtData_Voice_MixedHandler(void)
{
	SndParam_WriteLookupAndStore();
	switch (EXTDATA_TLV_OFFSET) {
	case 2:
		ExtData_ApplyTransposeEvent();
		break;
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
	}
}
