/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PanelTlv_PayloadOfTag */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near EXTDATA_NEW_VALUE;
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);
extern unsigned char __near ram_902a[];
extern unsigned char __near ram_902e[];
extern void SndParam_ApplyProgramChange(unsigned char *);
extern void Rhythm_LookupTempoVelocity_Wrap(void);
extern void SndParam_ApplyAndFetch(void);
extern void VoiceParam_CompareAndUpdate(unsigned char m);
extern void ExtData_SetTlvField(unsigned char m);


void SndParam_ApplyAndFetch(void)
{
	unsigned char b[6];
	unsigned char *s;
	unsigned char *d;
	unsigned char c;

	d = b;
	s = ram_902a;
	d[0] = s[0];
	d[1] = s[1];
	d[2] = c = s[2];
	if (c <= 0x1f) {
		SndParam_ApplyProgramChange(d);
		s = ram_902e;
		d = b;
		s[0] = d[3];
		s[1] = d[4];
	} else if (c == 0x48)
		Rhythm_LookupTempoVelocity_Wrap();
}

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

void ExtData_SetTlvField(unsigned char m)
{
	unsigned char *p;
	unsigned char v;

	if ((EXTDATA_MASK & m) == 0)
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
