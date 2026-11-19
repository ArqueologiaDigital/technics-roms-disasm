/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/audio_control_engine_m280.c (2026-11-19-29-p6-r46)
   sha256 2d85ea90a039d40a71c2db530f0bcb1ee70b4d870e51155696f15097de8a09cb (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near EXTDATA_NEW_VALUE;
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);
void VoiceParam_CompareAndUpdate(unsigned char m)
{
	unsigned char *p;
	unsigned char v;

	if ((EXTDATA_MASK & m) == 0)
		return;
	if ((EXTDATA_VALUE & m) == 0)
		return;
	p = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);
	if (p == (unsigned char *)-1L)
		return;
	p += EXTDATA_TLV_OFFSET;
	v = (~m & *p) | EXTDATA_VALUE;
	if (v == EXTDATA_NEW_VALUE)
		return;
	*p = v;
	EXTDATA_NEW_VALUE = v;
	MIDI_MSG_DATA2 = v;
	MIDI_MSG_DATA3 |= m;
}
