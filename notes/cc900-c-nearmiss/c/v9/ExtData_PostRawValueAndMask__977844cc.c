/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/audio_control_engine_m280.c (2026-11-16-111-p6-r22-staged)
   sha256 977844cc51bceac938a00d468143341eba7236aa20c23d3e289dbf462167a49e (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
