/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ExtData_SetTlvField ExtData_ToggleTlvBits MIDI_WriteResetSequence SwbtWr_FlushAndAppendParams */   /* staged module names, repair_module_lines.py */

extern unsigned char __near ram_90ea[];
extern unsigned char __near ram_90ee[];
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
    b = ram_90ea;
    b[0] = r[3]; b[1] = r[4]; b[2] = *t;
    Rhythm_DispatchNote_Finalize();
    b = ram_90ee;
    r[0] = b[0]; r[1] = b[1];
  }
}

void RegBitManip_Handler_4_Helper(void)
{
  unsigned char b[6];
  b[3] = ram_90ea[0]; b[4] = ram_90ea[1]; b[5] = ram_90ea[2];
  SndParam_ComputeVoiceIndex(b);
  ram_90ee[0] = b[0]; ram_90ee[1] = b[1]; ram_90ee[2] = b[2];
}

void SndBuf_WriteParamEntries(void)
{
  unsigned char b[6];
  b[0] = ram_90ea[0]; b[1] = ram_90ea[1]; b[2] = ram_90ea[2]; b[5] = ram_90ea[3];
  SndParam_CheckAndApplyMode(b);
  ram_90ee[0] = b[3]; ram_90ee[1] = b[4];
}

extern void ExtData_SetTlvField(unsigned int);
extern void SwbtWr_FlushAndAppendParams(void);
extern void MIDI_WriteResetSequence(void);
void ExtData_Voice_CheckMode3_Helper(void);
extern void MIDI_WriteResetSequence(void);

void MIDI_WriteResetSequence(void);

void ExtData_Voice_CheckMode3_Helper(void)
{
	ExtData_SetTlvField(128);
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-module: PanelTlv_PayloadOfTag */
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
extern void ExtData_PostRawValueAndMask(void);
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near EXTDATA_NEW_VALUE;
extern void SndParam_WriteLookupAndStore(void);

void ExtData_PostRawValueAndMask(void)
{
	MIDI_MSG_DATA2 = EXTDATA_VALUE;
	MIDI_MSG_DATA3 = EXTDATA_MASK;
	SwbtWr_FlushAndAppendParams();
}
void SndParam_WriteLookupAndStore(void)
{
	unsigned char *p = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);

	if (p == (unsigned char *)-1L) return;
	EXTDATA_NEW_VALUE = p[EXTDATA_TLV_OFFSET];
}

/* cc900-module: ExtData_ApplyTransposeEvent ExtData_StepTlvField SndParam_WriteLookupAndStore */
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

/* cc900-module: ExtData_Tag43_SetByte1Fields */
extern void ExtData_Drawbar_SetByte7Fields(void);
extern void ExtData_Tag43_SetByte1Fields(void);

void ExtData_Drawbar_SetByte7Fields(void)
{
	ExtData_SetTlvField(15);
	ExtData_ToggleTlvBits(48);
	SwbtWr_FlushAndAppendParams();
}
void ExtData_Tag43_SetByte1Fields(void)
{
	ExtData_SetTlvField(128);
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

typedef unsigned char *ucp;
extern unsigned int __near EXT_RECORD_OFFSET;
extern unsigned char __near PANEL_EVENT_QUEUE[];
extern ucp __near ram_912b;
extern void SndParam_FetchSequencerParams(void);

void SndParam_FetchSequencerParams(void)
{
    MIDI_MSG_STATUS = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    ram_912b = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);
    EXTDATA_TLV_OFFSET = MIDI_MSG_DATA1 = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    EXTDATA_VALUE = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    MIDI_MSG_DATA2 = 0;
    EXTDATA_MASK = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    MIDI_MSG_DATA3 = 0;
}

/* cc900-module: MIDI_WriteCommandToBuffer SwbtWr_WriteParamBlock */
extern void MIDI_WriteCommandToBuffer(int, int, int, int);
extern void MIDI_WriteMultiByteWithHeader(unsigned char *);
extern void MIDI_WriteMultiByteWithHeader(unsigned char *s);
extern unsigned char __near ram_917e;
extern unsigned char __near ram_917f;
extern unsigned char __near ram_9180;
extern unsigned char __near ram_9181;
extern void SwbtWr_WriteParamBlock(void);
extern void MIDI_WriteVoiceParamFromBuffer(void);
extern void Audio_InitSingleChannelParams(unsigned char a);
extern unsigned char __near ram_90fb[];
extern void MIDI_LoadParamsAndDispatchCC(void);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);
extern void Audio_SendModulationToParts(unsigned char a, unsigned char c);
extern unsigned int __near SWBTWR_WRITE_INDEX;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern void SwbtWr_AppendFixedParamBlock(void);

void MIDI_WriteMultiByteWithHeader(unsigned char *s)
{
    unsigned char ch;
    unsigned char n;
    unsigned char i;

    ch = *s++;
    n = *s++;
    MIDI_WriteCommandToBuffer(ch, 1, s[1], 0xff);
    MIDI_WriteCommandToBuffer(ch, 0, s[0], 0xff);
    n -= 2;
    i = 2;
    s += 2;
    while (n != 0) {
        MIDI_WriteCommandToBuffer(ch, i, *s, 0xff);
        n--;
        i++;
        s++;
    }
}
void Audio_InitSingleChannelParams(unsigned char a)
{
	MIDI_MSG_STATUS = 177;
	MIDI_MSG_DATA1 = a;
	MIDI_MSG_DATA2 = 0;
	MIDI_MSG_DATA3 = 64;
	SwbtWr_WriteParamBlock();
	MIDI_MSG_STATUS = 178;
	MIDI_MSG_DATA1 = a;
	MIDI_MSG_DATA2 = 0;
	MIDI_MSG_DATA3 = 127;
	SwbtWr_WriteParamBlock();
	MIDI_MSG_STATUS = 179;
	MIDI_MSG_DATA1 = a;
	MIDI_MSG_DATA2 = 127;
	MIDI_MSG_DATA3 = 127;
	SwbtWr_WriteParamBlock();
	ram_917e = a;
	ram_917f = 4;
	ram_9180 = 0;
	ram_9181 = 8;
	MIDI_WriteVoiceParamFromBuffer();
	MIDI_MSG_STATUS = a;
	MIDI_MSG_DATA1 = 4;
	MIDI_MSG_DATA2 = 0;
	MIDI_MSG_DATA3 = 8;
	SwbtWr_WriteParamBlock();
}
void Audio_SendModulationToParts(unsigned char a, unsigned char c)
{
	unsigned int i;
	unsigned char t;

	for (i = 0; i < 0x20; i++) {
		t = ram_90fb[i];
		if (t == 0xff) break;
		if (t == 2 && c != 2) continue;
		ram_917e = 178;
		ram_917f = ram_90fb[i];
		ram_9180 = a;
		ram_9181 = 127;
		MIDI_LoadParamsAndDispatchCC();
		if (PanelTlv_PayloadOfTag(ram_90fb[i])[13] & 0x20) continue;
		AddswbWr(ram_917e, ram_917f, ram_9180, ram_9181);
	}
}
void SwbtWr_AppendFixedParamBlock(void)
{
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = MIDI_MSG_STATUS;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = MIDI_MSG_DATA1;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = MIDI_MSG_DATA2;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = MIDI_MSG_DATA3;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX] = 0xff;
	MIDI_MSG_DATA3 = 0;
}
