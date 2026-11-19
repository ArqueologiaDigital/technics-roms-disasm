/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_2m280a.c (2026-11-19-19-p6-r43)
   sha256 a0751420ea09c5c677bc610fea4135369b9c53e11b79775664b65dead3d2b23b (tar-sha256); compiled at -Xr */
extern unsigned char __near EXTDATA_MASK;
extern unsigned char __near EXTDATA_NEW_VALUE;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern unsigned char __near MIDI_MSG_STATUS;
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
