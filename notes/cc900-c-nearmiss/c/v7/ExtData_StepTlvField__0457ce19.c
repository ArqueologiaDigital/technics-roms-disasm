/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/audio_control_engine_m280.c (2026-11-19-29-p6-r46)
   sha256 0457ce1906974f88e81891c2ec3e7524bf006819bee0d67efbc58c624d4cf0ec (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near EXTDATA_NEW_VALUE;
extern unsigned char __near ram_90b7;
extern unsigned char __near ram_90b8;
extern unsigned char __near ram_90b9;
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
	k = ram_90b7;
	if ((unsigned char)(v + k) < ram_90b8)
		v += k;
	else
		v = ram_90b9;
	v |= ~f & *p;
	if (v == EXTDATA_NEW_VALUE)
		return;
	*p = v;
	EXTDATA_NEW_VALUE = v;
	MIDI_MSG_DATA2 = v;
	MIDI_MSG_DATA3 |= f;
}
