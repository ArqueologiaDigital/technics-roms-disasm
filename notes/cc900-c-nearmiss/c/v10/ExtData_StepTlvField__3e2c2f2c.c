/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_1m280b.c (2026-11-19-15-p6-r42)
   sha256 3e2c2f2c8d752f18ee76e997facaf0b6a6d7b0698df2df202638db3eb051d305 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near EXTDATA_NEW_VALUE;
extern unsigned char __near ram_9153;
extern unsigned char __near ram_9154;
extern unsigned char __near ram_9155;
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);
void ExtData_StepTlvField(unsigned char m, unsigned char f)
{
	unsigned char *p;
	unsigned char v;
	unsigned char k;

	if ((m & EXTDATA_MASK) == 0)
		return;
	if ((m & EXTDATA_VALUE) == 0)
		return;
	p = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);
	if (p == (unsigned char *)-1L)
		return;
	p += EXTDATA_TLV_OFFSET;
	v = f & *p;
	k = ram_9153;
	if (v + k < ram_9154)
		v += k;
	else
		v = ram_9155;
	v |= *p & ~f;
	if (v == EXTDATA_NEW_VALUE)
		return;
	*p = v;
	EXTDATA_NEW_VALUE = v;
	MIDI_MSG_DATA2 = v;
	MIDI_MSG_DATA3 |= f;
}
