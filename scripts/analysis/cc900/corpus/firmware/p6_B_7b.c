/* Phase 6, helper B, round 7, form b (other C shapes of p6_B_7a.c): NoteMap_* pass &r directly; other
   declaration orders and temporaries. */

/* ---- audio/note_voice_mapping.s ---- */

extern void sendCOMM(int, int);
extern unsigned char __near ram_e197;
extern unsigned char __near ram_e2c2[];
extern unsigned char __near ram_e2cc[];

unsigned char SubCPU_RequestShortSoundName(unsigned char a, unsigned char c)
{
  unsigned char *p = ram_e2cc;
  p[0] = 0x2b; p[1] = 0x30; p[2] = 0x7f; p[3] = 0x24; p[4] = 0; p[5] = 0; p[6] = 2;
  ram_e197++;
  p[7] = ram_e197 & 0x7f;
  p[8] = a; p[9] = c;
  sendCOMM(3, 10);
  return ram_e2cc[7];
}

unsigned char Param_SignExtendRetu_Block4(unsigned char a, unsigned char c)
{
  unsigned char *p = ram_e2c2;
  p[0] = 0x2b; p[1] = 0x30; p[2] = 0x7f; p[3] = 0x22; p[4] = 0; p[5] = 0; p[6] = 2;
  ram_e197++;
  p[7] = ram_e197 & 0x7f;
  p[8] = a; p[9] = c;
  sendCOMM(3, 10);
  return ram_e2c2[7];
}

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern unsigned char __near AUDIO_STATE_SENT[];
extern void InitChannelState_Che_InitVal(struct nrec *);
extern void NoteMap_ProcessNoteEvent(struct nrec *, unsigned char *, unsigned int);
extern void NoteMap_ComputePitchOffset(struct nrec *, unsigned char *, unsigned int);
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
extern void Voice_ScanAndEmitMidiEvents(struct nrec *, unsigned int);
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
extern unsigned char NoteMap_CollectMatchingEntries(struct nrec *, void *, unsigned int, unsigned int);

void ProcessNoteOff_Done_Prologue(struct nrec *r, unsigned char *x, unsigned char e)
{
  InitChannelState_Che_InitVal(r);
  NoteMap_AllocNewVoiceEntry(r, e);
  if (x[(unsigned long)(e + 4u)] == e) NoteMap_SetChannelParam(r, e);
}

void NoteMap_ProcessRhythmNoteOn(struct nrec *r, unsigned char *x, unsigned char e)
{
  unsigned char v;
  NoteMap_ComputePitchOffset(r, x, e);
  NoteMap_AllocNewVoiceEntry(r, e);
  if (x[(unsigned long)((unsigned int)e + 4)] == e) NoteMap_SetChannelParam(r, e);
  v = x[(unsigned long)((unsigned int)e + 0x24)];
  if (v != 0xff && (x[e * 2 + 0x124] & 0x20)) Voice_ScanAndEmitMidiEvents(r, v);
}

void NoteMap_ProcessDualLayerNoteOff(unsigned char a, unsigned char c, unsigned char e)
{
  struct nrec r;
  if (c != 0xff && e != 0xff) {
    r.b2 = 2; r.b3 = a;
    NoteMap_ProcessNoteEvent(&r, AUDIO_STATE_SENT, e);
    r.b2 = 3; r.b3 = a;
    NoteMap_ProcessNoteEvent(&r, AUDIO_STATE_SENT, e);
  } else if (c == 0xff && e != 0xff) {
    r.b2 = 2; r.b3 = a;
    NoteMap_ProcessNoteEvent(&r, AUDIO_STATE_SENT, e);
    r.b2 = 3; r.b3 = a;
    NoteMap_ProcessNoteEvent(&r, AUDIO_STATE_SENT, e);
  }
}

void NoteMap_LookupAllocAndStoreResult(void *a, unsigned char *x, unsigned char e)
{
  struct nrec r;
 
  if (NoteMap_LookupVoice(&r, a, 0, e) != 0) {
   
    NoteMap_AllocNewVoiceEntry(&r, e);
    if (x[(unsigned long)((unsigned int)e + 4)] == e) NoteMap_SetChannelParam(&r, e);
  }
}

void NoteMap_LookupAndAllocVoice(void *a, unsigned char *x, unsigned char e)
{
  struct nrec r;
  unsigned char v;
 
  if (NoteMap_LookupVoice(&r, a, 0, e) != 0) {
   
    NoteMap_AllocNewVoiceEntry(&r, e);
    if (x[(unsigned long)((unsigned int)e + 4)] == e) NoteMap_SetChannelParam(&r, e);
    v = x[(unsigned long)((unsigned int)e + 0x24)];
    if (v != 0xff && (x[e * 2 + 0x124] & 0x20)) Voice_ScanAndEmitMidiEvents(&r, v);
  } else {
    if (x[(unsigned long)((unsigned int)e + 4)] == e) NoteMap_SetChannelParam(&r, e);
  }
}

void NoteMap_ProcessRhythmRemap(void *a, unsigned char *x, unsigned char e)
{
  struct nrec r;
  unsigned char v;
 
  if (NoteMap_CollectMatchingEntries(&r, a, 0, e) == 0) return;
 
  NoteMap_ComputePitchOffset(&r, x, e);
 
  NoteMap_AllocNewVoiceEntry(&r, e);
  if (x[(unsigned long)((unsigned int)e + 4)] == e) NoteMap_SetChannelParam(&r, e);
  v = x[(unsigned long)((unsigned int)e + 0x24)];
  if (v != 0xff && (x[e * 2 + 0x124] & 0x20)) Voice_ScanAndEmitMidiEvents(&r, v);
}

/* ---- sequencer/sequencer_engine.s (-O3 -Xr) ---- */

extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern unsigned int Part_ProcessAndDecrementVoice(void);
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned long __near SEQ_BLOCK_POOL;

/* the copy: the pool pointer is read twice (CSE'd into one load), source first */
void SeqLoad_ProcessAllVoiceData(void)
{
  unsigned char s, p;
  unsigned int w, b, t;
  unsigned int i;
  unsigned long od;
  unsigned char *pd;
  unsigned long os;
  unsigned char *ps;
  s = 1;
  do {
    p = 1;
    do {
      if (Part_ReadVoiceBit7(s, p) == 0) continue;
      w = Part_ReadVoiceWord(s, p);
      if (w == 0xffff) continue;
      if (w == 0xffff) continue;
      do {
        if (w == 1 || w == 2) {
          do {
            b = Part_ProcessAndDecrementVoice();
            if (b > 0x4d8) return;
          } while (b == 1 || b == 2);
          ps = (unsigned char *)SEQ_BLOCK_POOL;
          os = ((unsigned long)w - 1) << 8;
          pd = ps;
          od = ((unsigned long)b - 1) << 8;
          i = 0;
          do { pd[i + od] = ps[i + os]; i++; } while (i < 0x100);
          t = PartCtrl_ReadWord_Off1(w);
          if (t != 0) PartCtrl_WriteWord(t, b);
          else {
            Part_WriteVoiceWord(s, p, b);
            if ((unsigned char)(s - 1) == SEQ_CURRENT_SONG) Part_WriteVoiceWord(0, p, b);
          }
          t = PartCtrl_ReadWord(w);
          if (t != 0xffff) PartCtrl_WriteWord_Off1(t, b);
          else {
            Part_WriteWord_Indexed(s, p, b);
            if ((unsigned char)(s - 1) == SEQ_CURRENT_SONG) Part_WriteWord_Indexed(0, p, b);
          }
        }
        w = PartCtrl_ReadWord(w);
      } while (w != 0xffff);
    } while (++p <= 16);
  } while (++s <= 10);
  PartCtrl_SetClearBit7(1, 1);
  PartCtrl_WriteWord_Off1(1, 0);
  PartCtrl_WriteWord(1, 0xffff);
  PartCtrl_WriteByteToBuf(1, 5, 0x82);
  PartCtrl_SetClearBit7(2, 1);
  PartCtrl_WriteWord_Off1(2, 0);
  PartCtrl_WriteWord(2, 0xffff);
  PartCtrl_WriteByteToBuf(2, 5, 0x82);
}

extern unsigned int __near SEQ_ACTIVE_PARTS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near ram_28ae;
extern unsigned char __near ram_28a6;
extern unsigned char __near ram_230a;
extern unsigned char __near ram_1d94;
extern unsigned int __near ram_2314;
extern unsigned char __near ram_431;
extern unsigned char __near ram_347a;
extern unsigned char __near ACC_LANES_ENDING1;
extern unsigned char __near ACC_LANES_ENDING2;
extern unsigned char __near ACC_LANES_ENDED;
extern void SeqBuf_WriteNoteOffEntry(int);
extern void NoteMap_SendAllNotesOff(void);
extern void AudioInit_RefreshToneBank(void);
extern void VoiceAlloc_ProcessAll(void);
extern void AccompSeq_StopSequence(void);
extern void Audio_CheckSubsystemReady(void);
extern void SeqAcc_ProcessTempoEvents(void);
extern void BitMapOut_PrepareAndDisplaySimple(void);
/* cc900-name: SeqSyncPosMidiTiming=Seq_SyncPositionAndOutputMIDITiming */
extern void SeqSyncPosMidiTiming(void);
extern void AccWrap_FullStop(void);

unsigned char SeqPlay_HandlePlaybackEvent(void)
{
  unsigned char e, c, a;
  if (CURRENT_TITLE == 0x87 || CURRENT_TITLE == 0x88) { SeqAcc_ProcessTempoEvents(); return 0; }
  a = ram_230a;
  if (a & 0x02) { ram_230a = a & ~0x02; return 0; }
  ram_28ae &= ~0x80;
  ram_1d94 = 0;
  ram_2314 = SEQ_ACTIVE_PARTS;
  SEQ_ACTIVE_PARTS = 0;
  SeqBuf_WriteNoteOffEntry(0x32);
  NoteMap_SendAllNotesOff();
  AudioInit_RefreshToneBank();
  VoiceAlloc_ProcessAll();
  BitMapOut_PrepareAndDisplaySimple();
  AccompSeq_StopSequence();
  if (SEQ_TRACK_MASK != 0) {
    if (CURRENT_MODE == 19) {
      SEQ_TRACK_MASK = 0;
      Audio_CheckSubsystemReady();
      SEQ_ACTIVE_PARTS = 0;
    }
    SEQ_RTMCFG |= 0x04;
    SeqSyncPosMidiTiming();
    ram_431 = 0;
    Audio_CheckSubsystemReady();
    if (ram_347a & 0x04) {
      e = ACC_LANES_ENDING1;
      c = ACC_LANES_ENDING2;
      a = ACC_LANES_ENDED;
      if (e != 0 || c != 0 || a != 0) ram_28a6 &= ~0x01;
      else {
        ram_28a6 |= 0x01;
        ram_347a |= 0x02;
      }
    }
    if (ram_28a6 & 0x01) { AccWrap_FullStop(); SEQ_RTMCFG |= 0x02; }
    SEQ_RTMCFG &= ~0x04;
  }
  return 0;
}

extern unsigned char Part_ReadByteDirect(unsigned char, unsigned int);
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near ram_f460[];

void SeqLoad_ApplySongTempo(void)
{
  unsigned char *t, *s;
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

extern void AccWrap_PlayModeDispatch(void);
extern unsigned char __near PLAY_TRANSPORT_STATE;

void AccWrap_DispatchAndWaitSync(void)
{
  unsigned int n;
  AccWrap_PlayModeDispatch();
  n = 0xffff;
  if (PLAY_TRANSPORT_STATE & 0x04) do {
    if ((n -= 1) == 0) return;
  } while (PLAY_TRANSPORT_STATE & 0x04);
}
