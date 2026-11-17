/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_17m280.c (2026-11-16-123-p6-r25)
   sha256 37b558d6d8245b91fe5010bbf90678e81e403dec9d2a5b67236026af1f88e111 (tar-sha256); compiled at -O3 -Xr */
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
