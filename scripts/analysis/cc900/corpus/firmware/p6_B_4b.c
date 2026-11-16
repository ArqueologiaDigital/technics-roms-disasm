/* Phase 6, helper B, round 4, form b (other C shapes of p6_B_4a.c): routines WITH calls of v10's audio/note_voice_mapping.s,
   sequencer/sequencer_engine.s and audio/audio_control_engine.s, each under its firmware name.
   Callees are declared with the tree's names and adecl prototypes. */

/* ---- audio/note_voice_mapping.s ---- */

extern void sendCOMM(int, int);
extern void SendCOMM_VariableLengthPacket(unsigned char *, int, int);
extern unsigned char __near ram_e197;
extern unsigned char __near ram_e2b8[];
extern unsigned char __near ram_e2c2[];
extern unsigned char __near ram_e2cc[];
extern unsigned char __near ram_e2d6[];

/* sub-CPU requests {2B 30 7F op 00 00 02 seq A C} on COMM channel 3; L = the sequence byte */
unsigned char SubCPU_RequestSoundName(unsigned char a, unsigned char c)
{
  ram_e2b8[0] = 0x2b; ram_e2b8[1] = 0x30; ram_e2b8[2] = 0x7f; ram_e2b8[3] = 0x20; ram_e2b8[4] = 0; ram_e2b8[5] = 0; ram_e2b8[6] = 2;
  ram_e197++;
  ram_e2b8[7] = ram_e197 & 0x7f;
  ram_e2b8[8] = a; ram_e2b8[9] = c;
  sendCOMM(3, 10);
  return ram_e2b8[7];
}

unsigned char SndParam_LookupPartIndex(unsigned char a, unsigned char c)
{
  ram_e2d6[0] = 0x2b; ram_e2d6[1] = 0x30; ram_e2d6[2] = 0x7f; ram_e2d6[3] = 0x27; ram_e2d6[4] = 0; ram_e2d6[5] = 0; ram_e2d6[6] = 2;
  ram_e197++;
  ram_e2d6[7] = ram_e197 & 0x7f;
  ram_e2d6[8] = a; ram_e2d6[9] = c;
  sendCOMM(3, 10);
  return ram_e2d6[7];
}

unsigned char SubCPU_RequestShortSoundName(unsigned char a, unsigned char c)
{
  ram_e2cc[0] = 0x2b; ram_e2cc[1] = 0x30; ram_e2cc[2] = 0x7f; ram_e2cc[3] = 0x24; ram_e2cc[4] = 0; ram_e2cc[5] = 0; ram_e2cc[6] = 2;
  ram_e197++;
  ram_e2cc[7] = ram_e197;
  ram_e2cc[8] = a; ram_e2cc[9] = c;
  sendCOMM(3, 10);
  return ram_e2cc[7];
}

unsigned char Param_SignExtendRetu_Block4(unsigned char a, unsigned char c)
{
  ram_e2c2[0] = 0x2b; ram_e2c2[1] = 0x30; ram_e2c2[2] = 0x7f; ram_e2c2[3] = 0x22; ram_e2c2[4] = 0; ram_e2c2[5] = 0; ram_e2c2[6] = 2;
  ram_e197++;
  ram_e2c2[7] = ram_e197;
  ram_e2c2[8] = a; ram_e2c2[9] = c;
  sendCOMM(3, 10);
  return ram_e2c2[7];
}

/* set-if-changed COMM senders */
extern unsigned char __near ram_e35a;
extern unsigned char __near ram_e357;
extern unsigned char __near ram_e358;
extern unsigned char __near ram_e359;
extern unsigned char __near ram_e353;
extern unsigned char __near ram_e354;

void COMM_SendEqualizerOnOff(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e35a == c) return;
  ram_e35a = c;
  SendCOMM_VariableLengthPacket(&ram_e35a, 37, 1);
}

void SendPartDataBlock_ClearByte(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e357 == c) return;
  ram_e357 = c;
  SendCOMM_VariableLengthPacket(&ram_e357, 0x21, 1);
}

void SendPartDataBlock_ClearByte2(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e358 == c) return;
  ram_e358 = c;
  SendCOMM_VariableLengthPacket(&ram_e358, 0x22, 1);
}

void SendPartDataBlock_ClearByte3(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e359 == c) return;
  ram_e359 = c;
  SendCOMM_VariableLengthPacket(&ram_e359, 0x24, 1);
}

void COMM_SendMicVolume(unsigned char a)
{
  if (ram_e354 == a) return;
  ram_e354 = a;
  SendCOMM_VariableLengthPacket(&ram_e354, 7, 1);
}

void COMM_SendFadeLevel(unsigned char a)
{
  if (ram_e353 == a) return;
  ram_e353 = a;
  SendCOMM_VariableLengthPacket(&ram_e353, 6, 1);
}

/* MIDI senders through a 5-byte packet on the stack {length 4, status, data...} */
extern void MIDI_SendCmdPacket(unsigned char *);
extern void MIDI_PostSendStub(void);

void MIDI_SendControlChange(unsigned char ch, unsigned char cc, unsigned char v)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0xb0; b[2] = ch; b[3] = cc; b[4] = v;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}

void MIDI_SendChannelPressure(unsigned char ch, unsigned char v)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0xd0; b[2] = ch; b[3] = 0; b[4] = v;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}

void MIDI_SendPitchBend(unsigned char ch, unsigned int v)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0xe0; b[2] = ch;
  b[3] = (unsigned char)v & 0x7f;
  b[4] = (unsigned char)((v & 0x3fff) >> 7);
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern void InitChannelState_Che_InitVal(struct nrec *);
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);

void ProcessNoteOff_Done_Prologue(struct nrec *r, unsigned char *x, unsigned char e)
{
  InitChannelState_Che_InitVal(r);
  NoteMap_AllocNewVoiceEntry(r, e);
  if ((x + 4)[e] == e) NoteMap_SetChannelParam(r, e);
}

/* ---- sequencer/sequencer_engine.s (-O3 -Xr) ---- */

extern unsigned char SeqData_ReadNextByte(void);
extern void PartCtrl_RefreshWordPeriodic(void);
extern unsigned char __near ram_2586;
extern unsigned char __near ram_2587[];
extern unsigned char __near ram_28a6;
extern unsigned char __near ram_437;
extern unsigned char __near ram_436;

int SeqData_ReadParamBlock(void)
{
  unsigned int n = 0;
  unsigned char c;
  c = SeqData_ReadNextByte();
  ram_2586 = c;
  if (c == 0x82 || c == 0x84) return 0;
  do {
    PartCtrl_RefreshWordPeriodic();
    c = SeqData_ReadNextByte();
    if (c & 0x80) break;
    if (n < 5) {
      ram_2587[n] = c;
      n++;
      if (n >= 7) { ram_28a6 &= ~0x01; ram_437 = 0; ram_436 = 0; break; }
    }
  } while (1);
  return n;
}

extern unsigned char Part_ReadByteDirect(int, int);
extern void Part_WriteByte(int, int, int);
extern unsigned int Part_ReadWord(int, int);
extern void Part_WriteWord(int, int, int);
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near ram_f460[];

void SeqLoad_ApplySongTempo(void)
{
  unsigned char *s, *t;
  unsigned int o;
  unsigned char v;
  if (Part_ReadByteDirect(0, 5) != 1) return;
  v = Part_ReadByteDirect(0, 6);
  if (v != 7 && v != 8) return;
  s = PANEL_STYLE;
  t = s + 8;
  o = t - (unsigned char *)0xf980;
  *t = ram_f460[o];
  s[9] = ram_f460[o + 1];
}

extern unsigned char __near ram_f23e;

void SeqLoad_CheckAutoAccompFlag(void)
{
  if (Part_ReadByteDirect(0, 6) < 3) {
    ram_f23e |= 0x01;
    if (Part_ReadByteDirect(0, 5) == 0 && Part_ReadByteDirect(0, 6) < 3) ram_f23e &= ~0x01;
  }
  ram_f23e &= ~0x02;
}

extern unsigned char SEQ_CURRENT_SONG;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned char __near SEQ_RTMCFG;

void SeqLoad_RestorePartConfig(void)
{
  SEQ_CURRENT_SONG = Part_ReadByteDirect(1, 0xc7);
  Part_WriteByte(1, 0xc7, 0);
  SEQ_TRACK_MASK_COPY = Part_ReadWord(1, 0xc8);
  Part_WriteWord(1, 0xc8, 0);
  SEQ_START_MEASURE = 1;
  SEQ_RTMCFG &= ~0x08;
}

extern unsigned int __near SEQ_FREE_LIST_HEAD;

unsigned int SeqLoad_GetBlockRelocationOffset(void)
{
  if (SEQ_FREE_LIST_HEAD == 0) return 0;
  return SEQ_FREE_LIST_HEAD - 1;
}

extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void Part_WriteWordBlock_OffsetAF(unsigned int);

void VoiceChain_LinkAtEnd(unsigned int n)
{
  unsigned int h = SEQ_FREE_LIST_HEAD, v;
  if (h == 0) v = 0xffff;
  else { PartCtrl_WriteWord_Off1(h, n); v = h; }
  PartCtrl_WriteWord(n, v);
  PartCtrl_WriteWord_Off1(n, 0);
  Part_WriteWordBlock_OffsetAF(n);
}

extern unsigned char __near ram_2310;
extern unsigned int __near SEQ_TRACK_MASK;
extern void Audio_CheckSubsystemReady(void);
extern void AccWrap_PositionClear(void);
extern void SeqBuf_WriteNoteOffEntry(int);
extern void NoteMap_SendAllNotesOff(void);
extern void AudioInit_RefreshToneBank(void);
extern void VoiceAlloc_ProcessAll(void);
extern void BitMapOut_PrepareAndDisplay(void);

void SeqPlay_EmergencyStopAll(void)
{
  if (ram_2310 != 0) return;
  ram_2310 = 1;
  SEQ_TRACK_MASK = 0;
  Audio_CheckSubsystemReady();
  AccWrap_PositionClear();
  ram_28a6 &= ~0x01;
  SeqBuf_WriteNoteOffEntry(0x32);
  NoteMap_SendAllNotesOff();
  AudioInit_RefreshToneBank();
  VoiceAlloc_ProcessAll();
  BitMapOut_PrepareAndDisplay();
  ram_2310 = 0;
}

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern void SeqVoice_SetDefaultParams(void);
extern int SeqAccPlay_InitAndDispatch(void);
extern void SeqError_MapViaTableA(void);
extern void SeqVoice_InitReturnZero(void);

int SeqPart_InitWithValidation(void)
{
  int r;
  SeqVoice_SetDefaultParams();
  if (SeqAccPlay_InitAndDispatch()) {
    SEQ_ERROR_CODE = 3;
    SeqError_MapViaTableA();
    SeqVoice_InitReturnZero();
    r = -1;
  } else {
    SEQ_ERROR_CODE = 0;
    SEQ_EDIT_FLAGS &= ~0x40;
    r = 0;
  }
  return r;
}

unsigned char SeqPart_CheckVoiceType(unsigned char a)
{
  unsigned char t;
  a--;
  t = SEQ_TRACK_ASSIGN[a];
  if (t == 15 || t == 16 || t == 13) {
    SEQ_ERROR_CODE = 9;
    SeqError_MapViaTableA();
    SeqVoice_InitReturnZero();
    return 0xff;
  }
  return t;
}

extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int PartCtrl_ReadWord(unsigned int);

void SeqNote_QueueReturn(void)
{
  SEQ_DATA_OFFSET += 6;
  if (SEQ_DATA_OFFSET <= 0xff) return;
  SEQ_DATA_OFFSET -= 0x100;
  SEQ_DATA_OFFSET += 5;
  SEQ_DATA_BLOCK = PartCtrl_ReadWord(SEQ_DATA_BLOCK);
}

extern unsigned int __near ram_2875;
extern unsigned char __near ram_28a5;
extern void SeqAcc_InitPlaybackState(void);
extern void CtrlPanel_SetIndicatorBit(int);

void SeqAcc_RestorePlaybackState(void)
{
  unsigned int m = ram_2875;
  SEQ_TRACK_MASK = m;
  Audio_CheckSubsystemReady();
  if (m != 0) {
    SEQ_RTMCFG &= ~0x08;
    SeqAcc_InitPlaybackState();
    Audio_CheckSubsystemReady();
    ram_28a5 |= 0x01;
  } else ram_28a5 &= ~0x01;
  CtrlPanel_SetIndicatorBit(0x4c);
}

/* ACTIVE_TITLE read as a byte: ram_8d38 is its address */
extern unsigned char __near ram_8d38;
extern void ApDeliveryEvent(long, long, long);

void SeqMode_SendStatusUpdate(void)
{
  unsigned char t = ram_8d38;
  if (t == 0x87) ApDeliveryEvent(0x870003L, 0x1c0000fL, 1L);
  else if (t == 0x85) ApDeliveryEvent(0x850007L, 0x1c0000fL, 1L);
  else if (t == 0x81) ApDeliveryEvent(0x810005L, 0x1c0000fL, 1L);
}

/* ---- audio/audio_control_engine.s ---- */

extern unsigned char __near ram_90ea[];
extern unsigned char __near ram_90ee[];
extern void SndParam_FetchOscTableEntry(unsigned char *);
extern void Rhythm_DispatchNote_Finalize(void);

void SndParam_ResolveVoiceEntry(unsigned char *r)
{
  unsigned char *t = r + 2;
  if (*t <= 0x1f) SndParam_FetchOscTableEntry(r);
  else if (*t == 0x48) {
    ram_90ea[0] = r[3]; ram_90ea[1] = r[4]; ram_90ea[2] = *t;
    Rhythm_DispatchNote_Finalize();
    r[0] = ram_90ee[0]; r[1] = ram_90ee[1];
  }
}

extern unsigned char GetDialEnableState(void);
extern unsigned char CtrlPanel_GetSelectionState(void);
extern unsigned char __near ram_8f5e;
extern unsigned char __near ram_8f60;
extern unsigned int __near LED_REQUEST_3;
extern unsigned int __near LED_REQUEST_HOLD_3;

void Audio_CheckAndFlagChanges(void)
{
  unsigned char l;
  l = GetDialEnableState();
  if (ram_8f5e != l) { LED_REQUEST_3 |= 0x40; ram_8f5e = l; }
  l = CtrlPanel_GetSelectionState();
  if (ram_8f60 == l) return;
  if (l == 2) LED_REQUEST_HOLD_3 |= 0x04;
  if (ram_8f60 == 2) LED_REQUEST_HOLD_3 &= ~0x04;
  LED_REQUEST_3 |= 0x04;
  ram_8f60 = l;
}
