/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_902a[];
extern unsigned char __near ram_902e[];
extern void SndParam_FetchOscTableEntry(unsigned char *);
extern void Rhythm_DispatchNote_Finalize(void);
extern void SndParam_ComputeVoiceIndex(unsigned char *);
extern void SndParam_CheckAndApplyMode(unsigned char *);

void SndParam_ResolveVoiceEntry(unsigned char *r)
{
  unsigned char *t = r + 2;
  unsigned char *b;
  if (*t <= 0x1f) SndParam_FetchOscTableEntry(r);
  else if (*t == 0x48) {
    b = ram_902a;
    b[0] = r[3]; b[1] = r[4]; b[2] = *t;
    Rhythm_DispatchNote_Finalize();
    b = ram_902e;
    r[0] = b[0]; r[1] = b[1];
  }
}

void RegBitManip_Handler_4_Helper(void)
{
  unsigned char b[6];
  b[3] = ram_902a[0]; b[4] = ram_902a[1]; b[5] = ram_902a[2];
  SndParam_ComputeVoiceIndex(b);
  ram_902e[0] = b[0]; ram_902e[1] = b[1]; ram_902e[2] = b[2];
}

void SndBuf_WriteParamEntries(void)
{
  unsigned char b[6];
  b[0] = ram_902a[0]; b[1] = ram_902a[1]; b[2] = ram_902a[2]; b[5] = ram_902a[3];
  SndParam_CheckAndApplyMode(b);
  ram_902e[0] = b[3]; ram_902e[1] = b[4];
}

/* cc900-module: PanelTlv_PayloadOfTag SwbtWr_FlushAndAppendParams */
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near EXTDATA_NEW_VALUE;
extern void SndParam_WriteLookupAndStore(void);

void SndParam_WriteLookupAndStore(void)
{
	unsigned char *p = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);

	if (p == (unsigned char *)-1L) return;
	EXTDATA_NEW_VALUE = p[EXTDATA_TLV_OFFSET];
}

/* cc900-module: ExtData_ApplyTransposeEvent ExtData_StepTlvField ExtData_ToggleTlvBits SndParam_WriteLookupAndStore */
extern void SwbtWr_FlushAndAppendParams(void);
extern void ExtData_ToggleTlvBits(unsigned int);
extern void ExtData_ToggleReverbIllusionOnOff(void);

void ExtData_ToggleReverbIllusionOnOff(void)
{
	ExtData_ToggleTlvBits(192);
	SwbtWr_FlushAndAppendParams();
}

extern void SeqTimer_UpdateTempoReg(void);
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near MIDI_MSG_DATA1;
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
extern void ExtData_SetTempoIfChanged(void);

void ExtData_SetTempoIfChanged(void)
{
	unsigned char *s;

	s = PANEL_STYLE;
	if (s[8] == EXTDATA_VALUE && s[9] == EXTDATA_MASK) return;
	s[8] = EXTDATA_VALUE;
	s[9] = EXTDATA_MASK;
	MIDI_MSG_DATA2 = s[8];
	MIDI_MSG_DATA3 = 255;
	SwbtWr_FlushAndAppendParams();
	MIDI_MSG_DATA1 = 9;
	MIDI_MSG_DATA2 = s[9];
	MIDI_MSG_DATA3 = 1;
	SwbtWr_FlushAndAppendParams();
	SeqTimer_UpdateTempoReg();
}

extern unsigned char __near PANEL_DIGITAL_REVERB[];
extern unsigned char __near PANEL_EQUALIZER[];
extern unsigned char *CombinedPreset_Table[];
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void AssswbWr();
extern void SoundParam_NotifyChange(long, int, int);
extern void CombinedPreset_Load(unsigned char n);

void CombinedPreset_Load(unsigned char n)
{
    unsigned char *p;
    unsigned int i;

    p = CombinedPreset_Table[n];
    Mem_Copy(PANEL_DIGITAL_REVERB, p, 24);
    for (i = 0; i < 24; i++)
        AssswbWr(0x63, (unsigned char)i, PANEL_DIGITAL_REVERB[i], 0xff);
    Mem_Copy(PANEL_EQUALIZER, p + 24, 24);
    for (i = 0; i < 24; i++)
        AssswbWr(0x64, (unsigned char)i, PANEL_EQUALIZER[i], 0xff);
    SoundParam_NotifyChange(0x4002L, 0x7f, 1);
    SoundParam_NotifyChange(0x4006L, 1, 1);
}

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

typedef unsigned char *ucp;
extern unsigned int __near EXT_RECORD_OFFSET;
extern unsigned char __near PANEL_EVENT_QUEUE[];
extern ucp __near ram_906b;
extern void SndParam_FetchSequencerParams(void);

void SndParam_FetchSequencerParams(void)
{
    MIDI_MSG_STATUS = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    ram_906b = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);
    EXTDATA_TLV_OFFSET = MIDI_MSG_DATA1 = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    EXTDATA_VALUE = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    MIDI_MSG_DATA2 = 0;
    EXTDATA_MASK = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    MIDI_MSG_DATA3 = 0;
}
