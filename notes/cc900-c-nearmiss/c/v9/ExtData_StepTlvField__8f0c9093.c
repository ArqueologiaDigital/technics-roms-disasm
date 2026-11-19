/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/audio_control_engine_m280.c (2026-11-19-29-p6-r46)
   sha256 8f0c9093a6e8a4dfefe209c9ca7b5da4926ac5131966e1fa13cdb0fa6e147b9c (tar-sha256); compiled at -Xr
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

	if ((EXTDATA_MASK & m) == 0)
		return;
	if ((EXTDATA_VALUE & m) == 0)
		return;
	p = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);
	if (p == (unsigned char *)-1L)
		return;
	p = &p[EXTDATA_TLV_OFFSET];
	v = *p & f;
	k = ram_9153;
	if ((unsigned char)(v + k) < ram_9154)
		v += k;
	else
		v = ram_9155;
	v |= ~f & *p;
	if (v == EXTDATA_NEW_VALUE)
		return;
	*p = v;
	EXTDATA_NEW_VALUE = v;
	MIDI_MSG_DATA2 = v;
	MIDI_MSG_DATA3 |= f;
}
