/* Phase 6, helper B, round 5, form b (other C shapes of p6_B_5a.c): one-spot fixes of round 4 and new routines with calls of v10's
   audio/note_voice_mapping.s, sequencer/sequencer_engine.s and audio/audio_control_engine.s. */

/* ---- audio/note_voice_mapping.s ---- */

extern void sendCOMM(int, int);
extern void SendCOMM_VariableLengthPacket(unsigned char *, int, int);
extern unsigned char __near ram_e197;
extern unsigned char __near ram_e2c2[];
extern unsigned char __near ram_e2cc[];

unsigned char SubCPU_RequestShortSoundName(unsigned char a, unsigned char c)
{
  unsigned char *p = ram_e2cc;
  unsigned char s;
  p[0] = 0x2b; p[1] = 0x30; p[2] = 0x7f; p[3] = 0x24; p[4] = 0; p[5] = 0; p[6] = 2;
  ram_e197++;
  s = ram_e197;
  p[7] = s;
  p[8] = a; p[9] = c;
  sendCOMM(3, 10);
  return ram_e2cc[7];
}

unsigned char Param_SignExtendRetu_Block4(unsigned char a, unsigned char c)
{
  unsigned char *p = ram_e2c2;
  unsigned char s;
  p[0] = 0x2b; p[1] = 0x30; p[2] = 0x7f; p[3] = 0x22; p[4] = 0; p[5] = 0; p[6] = 2;
  ram_e197++;
  s = ram_e197;
  p[7] = s;
  p[8] = a; p[9] = c;
  sendCOMM(3, 10);
  return ram_e2c2[7];
}

/* set-if-changed COMM senders: the call is not in tail position in the firmware (call + ret, no jump) */
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
  if (ram_e35a != c) { ram_e35a = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe35a, 37, 1); }
}

void SendPartDataBlock_ClearByte(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e357 != c) { ram_e357 = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe357, 0x21, 1); }
}

void SendPartDataBlock_ClearByte2(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e358 != c) { ram_e358 = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe358, 0x22, 1); }
}

void SendPartDataBlock_ClearByte3(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e359 != c) { ram_e359 = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe359, 0x24, 1); }
}

void COMM_SendMicVolume(unsigned char a)
{
  unsigned char *p = (unsigned char *)0xe354;
  if (*p == a) return;
  *p = a;
  SendCOMM_VariableLengthPacket(p, 7, 1);
}

void COMM_SendFadeLevel(unsigned char a)
{
  unsigned char *p = (unsigned char *)0xe353;
  if (*p == a) return;
  *p = a;
  SendCOMM_VariableLengthPacket(p, 6, 1);
}

extern void MIDI_SendCmdPacket(unsigned char *);
extern void MIDI_PostSendStub(void);

void SubCPU_SendSystemRecord(unsigned char a, unsigned char c, unsigned char e)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0xf0; b[2] = a; b[3] = c; b[4] = e;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}

void Rhythm_DispatchCCCommand(unsigned char a, unsigned char c)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0x90; b[2] = 0x19; b[3] = a; b[4] = c;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern void InitChannelState_Che_InitVal(struct nrec *);
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);

void ProcessNoteOff_Done_Prologue(struct nrec *r, unsigned char *x, unsigned char e)
{
  unsigned long k;
  InitChannelState_Che_InitVal(r);
  NoteMap_AllocNewVoiceEntry(r, e);
  k = e + 4;
  if (x[k] == e) NoteMap_SetChannelParam(r, e);
}

extern int SndParam_LookupReadOnly(long);

unsigned char Note_CheckTransposeRange(unsigned char a, unsigned char c)
{
  if (SndParam_LookupReadOnly(0xc0L) == 1) {
    if (c == 0x78) return 1;
    return 0;
  }
  if ((a & 0xf0) == 0xf0) return 1;
  return 0;
}

extern int SndParam_LookupViaEncode(int, int);
extern void SndParam_FetchOscTableEntry(unsigned char *);
extern unsigned char __near CURRENT_TITLE;

unsigned char SelectTone_Continue_Prologue(unsigned char a)
{
  unsigned char b[6];
  if (CURRENT_TITLE != 246) return a;
  b[3] = SndParam_LookupViaEncode(0, 0);
  b[4] = SndParam_LookupViaEncode(0, 0x20);
  b[2] = 0;
  SndParam_FetchOscTableEntry(b);
  return b[0] + 0xf0;
}

void SndParam_ApplyVoiceValue(unsigned char *r)
{
  unsigned char *q;
  int h;
  if (r[5] == 0x0f) {
    r[3] = r[2];
    r[4] = 0x78;
    return;
  }
  h = SndParam_LookupViaEncode(r[5], 0x20);
  q = r + 4;
  r[3] = r[2];
  if (h == 0x78) *q = 0x78; else *q = r[1];
}

/* ---- sequencer/sequencer_engine.s ---- */

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
  for (;;) {
    PartCtrl_RefreshWordPeriodic();
    c = SeqData_ReadNextByte();
    if (c & 0x80) break;
    if (n >= 5) continue;
    *(n + ram_2587) = c;
    n++;
    if (n >= 7) { ram_28a6 &= ~0x01; ram_437 = 0; ram_436 = 0; break; }
  }
  return n;
}

extern unsigned char Part_ReadByteDirect(unsigned char, unsigned int);
extern void Part_WriteByte(unsigned char, unsigned int, unsigned char);
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
  *t = o[ram_f460];
  s[9] = (o + 1)[ram_f460];
}

extern unsigned char __near ram_f23e;

void SeqLoad_CheckAutoAccompFlag(void)
{
  if (Part_ReadByteDirect(0, 6) >= 3) goto skip;
  ram_f23e |= 0x01;
  if (Part_ReadByteDirect(0, 5) != 0) goto skip;
  if (Part_ReadByteDirect(0, 6) >= 3) goto skip;
  ram_f23e &= ~0x01;
skip:
  goto clear;
clear:
  ram_f23e &= ~0x02;
}

extern unsigned char SEQ_CURRENT_SONG;
extern unsigned char *SeqStep_ReinitPartTable(void);
extern void SeqData_CopyBlockToBuffer(unsigned int);
extern unsigned char __near ram_8d88;

unsigned char *SeqSavePre(void)
{
  unsigned char *r = SeqStep_ReinitPartTable();
  SeqData_CopyBlockToBuffer(SEQ_CURRENT_SONG);
  Part_WriteByte(1, 4, 1);
  return r;
}

void SeqSavePost(int e)
{
  Part_WriteByte(1, 4, 0);
  if (e >= 0) ram_8d88 &= ~0x01;
}

extern void SetVisible(long, unsigned int);

void VoiceParam_SetD6Group(unsigned char a)
{
  unsigned int v = a ? 1 : 0;
  SetVisible(0xd60003L, v);
  SetVisible(0xd60004L, v);
  SetVisible(0xd60005L, v);
  SetVisible(0xd60006L, v);
}

extern void AccWrap_PlayModeDispatch(void);
extern unsigned char __near PLAY_TRANSPORT_STATE;

void AccWrap_DispatchAndWaitSync(void)
{
  unsigned int n;
  AccWrap_PlayModeDispatch();
  n = 0xffff;
  while (PLAY_TRANSPORT_STATE & 0x04) {
    if (--n == 0) return;
  }
}

extern int FileIO_SeekAndReadBlock(unsigned long, unsigned int);
extern int FileIO_ReadByte_BufferHit(unsigned int);

long FileIO_SeekReadAndCheck(unsigned long a, unsigned char c)
{
  long r = FileIO_SeekAndReadBlock(a, 0);
  if (r == 0) r = FileIO_ReadByte_BufferHit(c);
  return r;
}

extern void SeqError_MapViaTableF(void);
extern void SeqVoice_InitReturnZero(void);
extern unsigned char __near ram_2879;
extern unsigned char __near ram_289d;

void SeqPart_ByteBlockA95A_Code_Helper(void)
{
  SeqError_MapViaTableF();
  SeqVoice_InitReturnZero();
  ram_2879 &= ~0x01;
  ram_2879 &= ~0x02;
  ram_289d &= ~0x01;
  ram_289d &= ~0x04;
}

extern unsigned char PartCtrl_TestBit7(unsigned int);

int VoiceAlloc_CheckRangeAndBit7(unsigned int n)
{
  if (n <= 0x4d8 && n != 0 && PartCtrl_TestBit7(n)) return 0;
  return -1;
}

extern unsigned int Part_ProcessAndDecrementVoice(void);
extern void Part_SetClearVoiceBit7(unsigned int, unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
extern void Chan_SetActiveBit(unsigned int, unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern unsigned char __near ram_2684;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned int __near SEQOP_PRIMARY_OFFSET;

int SeqPart_AllocNewEntry(unsigned char a)
{
  unsigned char t;
  unsigned int b = Part_ProcessAndDecrementVoice();
  if (b == 0xffff) return -1;
  t = ram_2684;
  t--;
  SEQ_TRACK_ASSIGN[t] = a;
  Part_SetClearVoiceBit7(0, ram_2684, 1);
  Part_WriteVoiceWord(0, ram_2684, b);
  SEQOP_PRIMARY_BLOCK = b;
  SEQOP_PRIMARY_OFFSET = 5;
  PartCtrl_WriteWord_Off1(b, 0);
  PartCtrl_WriteWord(b, 0xffff);
  return 0;
}

unsigned int PartCtrl_CheckOwnerAndToggle(unsigned int n, unsigned int o, unsigned int m)
{
  unsigned int r = 0;
  if (PartCtrl_ReadWord_Off1(n) != o) r |= 0x10;
  else if (m == 0 && PartCtrl_TestBit7(n) != 0) { PartCtrl_SetClearBit7(n, 0); r |= 0x02; }
  else if (m == 1 && PartCtrl_TestBit7(n) == 0) { PartCtrl_SetClearBit7(n, 1); r |= 0x04; }
  return r;
}

void Part_ClearVoiceSlot(unsigned char a, unsigned char c)
{
  Part_WriteWord_Indexed(a, c, 0xffff);
  Part_WriteByte_Indexed(a, c, 5);
  Part_SetClearVoiceBit7(a, c, 0);
  Part_WriteVoiceWord(a, c, 0xffff);
  if (a == 0) Chan_SetActiveBit(c, 0);
}

/* ---- audio/audio_control_engine.s ---- */

extern unsigned char __near ram_90ea[];
extern unsigned char __near ram_90ee[];
extern void SndParam_CheckAndApplyMode(unsigned char *);
extern void SndParam_ComputeVoiceIndex(unsigned char *);

void SndBuf_WriteParamEntries(void)
{
  unsigned char b[6];
  b[0] = ram_90ea[0]; b[1] = ram_90ea[1]; b[2] = ram_90ea[2]; b[5] = ram_90ea[3];
  SndParam_CheckAndApplyMode(b);
  ram_90ee[0] = b[3]; ram_90ee[1] = b[4];
}

void RegBitManip_Handler_4_Helper(void)
{
  unsigned char b[6];
  b[3] = ram_90ea[0]; b[4] = ram_90ea[1]; b[5] = ram_90ea[2];
  SndParam_ComputeVoiceIndex(b);
  ram_90ee[0] = b[0]; ram_90ee[1] = b[1]; ram_90ee[2] = b[2];
}
