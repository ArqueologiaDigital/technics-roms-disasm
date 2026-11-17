/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/audio_control_engine_m280.c (2026-11-17-1-p6-r28-staged)
   sha256 e62c20abf1969254e262ed0a84f03cd8872f37d75470ecb10e7d50f1021134f3 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void SwbtWr_FlushAndAppendParams(void);
extern void SeqTimer_UpdateTempoReg(void);
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near MIDI_MSG_DATA1;
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
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
