/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/audio_control_engine_m0_xr.c (2026-11-16-92-p6-r18)
   sha256 42ef26d83e1dcb6eb97b134ad744accbf089de12fa16d7ad6248165b443c4635 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern void ExtData_SetTlvField(unsigned int);
extern void ExtData_ToggleTlvBits(unsigned int);
extern void SwbtWr_FlushAndAppendParams(void);
extern unsigned char __near ram_90f9;
extern unsigned char __near PANEL_CONDUCTOR[];
extern unsigned char __near PANEL_STYLE[];
extern void MIDI_WriteResetSequence(void);
extern void MIDI_WriteResetSequence(void);
void ExtData_Voice_UpdateFlags(void)
{
	unsigned char *c;
	unsigned char a;

	ExtData_ToggleTlvBits(2);
	ExtData_SetTlvField(1);
	SwbtWr_FlushAndAppendParams();
	c = PANEL_CONDUCTOR;
	if (c[3] & 1) return;
	if ((PANEL_STYLE[3] & 7) != 1) return;
	c++;
	a = *c;
	if (a & 2) {
		ram_90f9 |= 1;
		a = *c;
		a &= ~2;
		*c = a;
		MIDI_WriteResetSequence();
	}
}
