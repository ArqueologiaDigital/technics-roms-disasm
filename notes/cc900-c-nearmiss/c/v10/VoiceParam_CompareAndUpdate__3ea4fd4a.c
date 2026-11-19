/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_2m280b.c (2026-11-19-19-p6-r43)
   sha256 3ea4fd4a85287fc23bab29dcedd0b94658ce6acf592acaa2357e53a514dcdc2d (tar-sha256); compiled at -O3 -Xr */
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

	if ((m & EXTDATA_MASK) != 0 && (m & EXTDATA_VALUE) != 0) {
		p = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);
		if (p != (unsigned char *)-1L) {
			p = &p[EXTDATA_TLV_OFFSET];
			v = *p & ~m | EXTDATA_VALUE;
			if (v != EXTDATA_NEW_VALUE) {
				*p = v;
				EXTDATA_NEW_VALUE = v;
				MIDI_MSG_DATA2 = v;
				MIDI_MSG_DATA3 |= m;
			}
		}
	}
}
