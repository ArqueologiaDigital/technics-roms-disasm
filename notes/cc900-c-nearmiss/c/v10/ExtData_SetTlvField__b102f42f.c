/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_2m280a.c (2026-11-19-15-p6-r42)
   sha256 b102f42f168fdbe81392fdc83f72714d7f2ac737d6fe5ccdb00ce1fecd792e2c (tar-sha256); compiled at -O3 -Xr */
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);
extern unsigned char __near EXTDATA_MASK;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_NEW_VALUE;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
void ExtData_SetTlvField(unsigned char m)
{
	unsigned char *p;
	unsigned char v;

	if ((m & EXTDATA_MASK) == 0)
		return;
	p = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);
	if (p == (unsigned char *)-1L)
		return;
	p += EXTDATA_TLV_OFFSET;
	v = (*p & ~m) | EXTDATA_VALUE;
	if (v == EXTDATA_NEW_VALUE)
		return;
	*p = v;
	EXTDATA_NEW_VALUE = v;
	MIDI_MSG_DATA2 = v;
	MIDI_MSG_DATA3 |= m;
}
