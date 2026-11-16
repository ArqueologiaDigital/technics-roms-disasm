/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/audio_control_engine_m0_xr.c (2026-11-16-92-p6-r18)
   sha256 c66d685a072a9c7fc386b6ede6692bbe34dd0e1955cd4d712c711c4510c3e4ea (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern void ExtData_SetTlvField(unsigned int);
extern void ExtData_ToggleTlvBits(unsigned int);
extern void SwbtWr_FlushAndAppendParams(void);
extern unsigned char __near ram_905d;
extern unsigned char __near PANEL_CONDUCTOR[];
extern unsigned char __near PANEL_STYLE[];
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
		ram_905d |= 1;
		a = *c;
		a &= ~2;
		*c = a;
		MIDI_WriteResetSequence();
	}
}
