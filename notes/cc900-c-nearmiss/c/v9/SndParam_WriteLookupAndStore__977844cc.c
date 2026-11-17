/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/audio_control_engine_m280.c (2026-11-16-111-p6-r22-staged)
   sha256 977844cc51bceac938a00d468143341eba7236aa20c23d3e289dbf462167a49e (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near EXTDATA_NEW_VALUE;
void SndParam_WriteLookupAndStore(void)
{
	unsigned char *p = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);

	if (p == (unsigned char *)-1L) return;
	EXTDATA_NEW_VALUE = p[EXTDATA_TLV_OFFSET];
}
