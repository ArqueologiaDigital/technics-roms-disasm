/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_14m280.c (2026-11-16-100-p6-r19)
   sha256 7f0719658bdaa085c557506cd92bd277c660b461d452acc191cb8ca0490feca2 (tar-sha256); compiled at -O3 -XS -Xr */
extern void SwbtWr_FlushAndAppendParams(void);
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
void ExtData_PostRawValueAndMask(void)
{
	MIDI_MSG_DATA2 = EXTDATA_VALUE;
	MIDI_MSG_DATA3 = EXTDATA_MASK;
	SwbtWr_FlushAndAppendParams();
}
