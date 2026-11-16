/* Phase 6, helper B, round 6, form a: larger routines with calls of v10's sequencer/sequencer_engine.s and
   audio/note_voice_mapping.s, each under its firmware name.  Callees are declared with the tree's names and adecl
   prototypes; __near: the ROM reaches the cell with a 16-bit absolute operand, plain: 24-bit. */

/* ---- sequencer/sequencer_engine.s ---- */

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
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_SetClearVoiceBit7(unsigned int, unsigned int, unsigned int);
extern void Part_StealAndReallocVoices(unsigned int);
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned long __near SEQ_BLOCK_POOL;

/* Copies every voice block chain of song slots 1..10 into newly allocated blocks (0x100 bytes each) */
void SeqLoad_ProcessAllVoiceData(void)
{
  unsigned char s, p;
  unsigned int w, b, t, i;
  unsigned char *ps, *pd;
  unsigned long os, od;
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

extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_ERROR_CODE;
extern void SeqVoice_SetDefaultParams(void);
extern void SeqVoice_InitReturnZero(void);
extern int Seq_ValidatePartNumber(unsigned int);

void SeqPart_InitClear(void)
{
  unsigned int v;
  SeqVoice_SetDefaultParams();
  if (Seq_ValidatePartNumber(SEQ_TRACK) != 0) SEQ_ERROR_CODE = 3;
  else {
    Part_WriteWord_Indexed(0, SEQ_TRACK, 0xffff);
    Part_WriteByte_Indexed(0, SEQ_TRACK, 5);
    if (Part_ReadVoiceBit7(0, SEQ_TRACK) != 0) {
      Part_SetClearVoiceBit7(0, SEQ_TRACK, 0);
      v = Part_ReadVoiceWord(0, SEQ_TRACK);
      if (v != 0xffff) {
        Part_WriteVoiceWord(0, SEQ_TRACK, 0xffff);
        Part_StealAndReallocVoices(v);
      }
    }
  }
  SeqVoice_InitReturnZero();
  Part_SetClearVoiceBit7((unsigned char)(SEQ_CURRENT_SONG + 1), SEQ_TRACK, 0);
  Part_WriteVoiceWord((unsigned char)(SEQ_CURRENT_SONG + 1), SEQ_TRACK, 0xffff);
  Part_WriteWord_Indexed((unsigned char)(SEQ_CURRENT_SONG + 1), SEQ_TRACK, 0xffff);
  Part_WriteByte_Indexed((unsigned char)(SEQ_CURRENT_SONG + 1), SEQ_TRACK, 5);
}

extern unsigned char __near SEQ_PLAY_FLAGS;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near SEQ_ACTIVE_PARTS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near ram_22fc;
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
extern void AccWrap_PlayModeStopExpr(void);
extern void AccWrap_PlayModeDispatch(void);
extern void SeqBuf_WriteNoteOffEntry(int);
extern void NoteMap_SendAllNotesOff(void);
extern void AudioInit_RefreshToneBank(void);
extern void VoiceAlloc_ProcessAll(void);
extern void AccompSeq_StopSequence(void);
extern void MidiChannel_ResetAndConfigure(void);
extern void Audio_CheckSubsystemReady(void);
extern void UI_PostTimerResetEvent(void);
extern void Demo_SelectEntry_AfterSongLoad(void);
extern void SeqAcc_ProcessTempoEvents(void);
extern void BitMapOut_PrepareAndDisplaySimple(void);
/* cc900-name: SeqSyncPosMidiTiming=Seq_SyncPositionAndOutputMIDITiming */
extern void SeqSyncPosMidiTiming(void);
extern void AccWrap_FullStop(void);

void SeqPlay_StopAndResetAll(void)
{
  unsigned char a, f;
  if (SEQ_PLAY_FLAGS & 0x01) {
    if (SEQ_REC_TRACKS == 0) ram_22fc = 0;
    return;
  }
  a = ACC_TRANSPORT_STATE;
  if (!(a & 0x08) && (a & 0x04)) {
    if (!(SEQ_TRANSPORT_STATE & 0x04)) return;
    AccWrap_PlayModeStopExpr();
    ram_22fc = 0;
  } else AccWrap_PlayModeDispatch();
  SEQ_CONTROL_FLAGS &= ~0x20;
  SeqBuf_WriteNoteOffEntry(0x32);
  NoteMap_SendAllNotesOff();
  AudioInit_RefreshToneBank();
  VoiceAlloc_ProcessAll();
  AccompSeq_StopSequence();
  ram_28ae &= ~0x80;
  MidiChannel_ResetAndConfigure();
  SEQ_RTMCFG &= ~0x08;
  SEQ_START_MEASURE = 1;
  SEQ_ACTIVE_PARTS = 0;
  f = SEQ_CONTROL_FLAGS;
  f |= 0x10;
  f |= 0x04;
  SEQ_CONTROL_FLAGS = f;
  ram_22fc = 0;
  if (CURRENT_MODE == 19) {
    SEQ_TRACK_MASK = 0;
    Audio_CheckSubsystemReady();
    SEQ_ACTIVE_PARTS = 0;
    UI_PostTimerResetEvent();
    Demo_SelectEntry_AfterSongLoad();
  }
}

unsigned char SeqPlay_HandlePlaybackEvent(void)
{
  unsigned char a, e, c, t;
  if (CURRENT_TITLE == 0x87 || CURRENT_TITLE == 0x88) { SeqAcc_ProcessTempoEvents(); return 0; }
  a = ram_230a;
  if (a & 0x02) { a &= ~0x02; ram_230a = a; return 0; }
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
        t = ram_347a;
        t |= 0x02;
        ram_347a = t;
      }
    }
    if (ram_28a6 & 0x01) { AccWrap_FullStop(); SEQ_RTMCFG |= 0x02; }
    SEQ_RTMCFG &= ~0x04;
  }
  return 0;
}

/* ---- audio/note_voice_mapping.s (the part built without -O) ---- */

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
struct xpair { unsigned char f0, f1; };
struct xs { unsigned char hdr[4]; unsigned char ch[32]; unsigned char map[256]; struct xpair pr[128]; };
extern unsigned char __near AUDIO_STATE_SENT[];
extern void NoteMap_ProcessNoteEvent(struct nrec *, unsigned char *, unsigned int);
extern void NoteMap_ComputePitchOffset(struct nrec *, struct xs *, unsigned int);
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
extern void Voice_ScanAndEmitMidiEvents(struct nrec *, unsigned int);
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);

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

void NoteMap_ProcessRhythmNoteOn(struct nrec *r, struct xs *x, unsigned char e)
{
  unsigned char v;
  NoteMap_ComputePitchOffset(r, x, e);
  NoteMap_AllocNewVoiceEntry(r, e);
  if (x->ch[e] == e) NoteMap_SetChannelParam(r, e);
  v = x->map[e];
  if (v != 0xff && (x->pr[e].f0 & 0x20)) Voice_ScanAndEmitMidiEvents(r, v);
}

void NoteMap_LookupAllocAndStoreResult(void *a, struct xs *x, unsigned char e)
{
  struct nrec r;
  if (NoteMap_LookupVoice(&r, a, 0, e) != 0) {
    NoteMap_AllocNewVoiceEntry(&r, e);
    if (x->ch[e] == e) NoteMap_SetChannelParam(&r, e);
  }
}

void NoteMap_LookupAndAllocVoice(void *a, struct xs *x, unsigned char e)
{
  struct nrec r;
  unsigned char v;
  if (NoteMap_LookupVoice(&r, a, 0, e) != 0) {
    NoteMap_AllocNewVoiceEntry(&r, e);
    if (x->ch[e] == e) NoteMap_SetChannelParam(&r, e);
    v = x->map[e];
    if (v != 0xff && (x->pr[e].f0 & 0x20)) Voice_ScanAndEmitMidiEvents(&r, v);
  } else {
    if (x->ch[e] == e) NoteMap_SetChannelParam(&r, e);
  }
}
