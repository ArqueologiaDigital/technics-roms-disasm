/* Phase 6, helper B, round 21, form a: v10 sequencer/sequencer_engine.s (-O3 -Xr / -Xr).
   Refinements of run r31 (one spot each), then three new routines.  Parked: ScanAndStore, the StoreResult pair,
   CheckRepeatAndReactivate, ReassignVoiceState.
   - SetupVoice (+146): the record index s * 9 computed into a local before the base is loaded (the ROM: muls bc
     first, then lda xde, base, then lda (xde+bc));
   - AdvanceWithWrap (+1): `a + offset` (the ROM widens A into BC first, then loads the offset into WA);
   - HandleChannelState (+9 at -Xr): the REC test through a local (the ROM keeps m & SEQ_REC_TRACKS in DE);
   - DeactivateVoiceChannel (+26): the part as an int local before the transport test (the ROM widens A there
     and uses it on both paths);
   - new: SeqEvt_SelectNearestTiming, Rhythm_ComputeNoteAllocation, Part_ValidateVoiceAndSetupSeq.
   PartCtrl_WriteByteToBuf (r31: +2) was not retried: the work stopped before its one-function files were
   written; the next idea was a constant-address 2D array, ((unsigned char (*)[256])0xb0000)[b - 1][o]. */
/* cc900-module: Accomp_ValidateAutoPlayChordVoice Chan_SetActiveBit NotePool_InsertEntry PartCtrl_ReadWord Part_DeactivateChannel Part_IsVoiceActive Part_ReadVoiceByte Part_SendVoiceOffAndCCEvents Part_ValidateVoiceChannel Rhythm_DispatchNoteAlloc SeqBuf_WriteNoteOffEntry SeqData_ReadNextByte SeqPlay_FindAndActivateVoice SeqPlay_InitStartState SeqStep_HandleNoteOverflow SeqTiming_CompareAndUpdateState SeqVoice_ActivateWithBarSync SeqVoice_DeactivateAndReinit VoiceAlloc_ProcessAll VoiceAlloc_TestBitHigh */

struct rec8 { unsigned int w; unsigned char b[6]; };
extern struct rec8 __near ram_2338[];
extern unsigned char __near ram_1db6[];
#define REC_2338 ((struct rec8 *)ram_2338)

extern unsigned char __near ram_231a;
extern void SeqData_SetErrorCode(unsigned char);
extern unsigned char __near ram_1db4;
extern void NoteMap_RemoveHeadEntry(unsigned int);
extern void NotePool_InsertEntry(unsigned char);

unsigned char SeqNote_SetupVoice(unsigned char a, unsigned char *p)
{
  unsigned int w;
  unsigned char *e;
  int k;
  unsigned char n;
  unsigned char s;
  s = ram_1db4;
  if (s == 0xff) return 1;
  if (a == 0) SeqData_SetErrorCode(0x0d);
  if (s >= 0x40) SeqData_SetErrorCode(0x0e);
  NoteMap_RemoveHeadEntry(s);
  w = REC_2338[(unsigned char)(a - 1)].w;
  n = REC_2338[(unsigned char)(a - 1)].b[1];
  n += p[4];
  if (n >= 0x60) { n -= 0x60; w++; }
  w += p[5];
  if (a == 0x11) a = ram_231a;
  if (n > 0x60) SeqData_SetErrorCode(0x0f);
  k = (int)s * 9;
  e = (unsigned char *)ram_1db6;
  e += k;
  e[4] = p[0];
  e[5] = n;
  e[6] = p[2];
  e[7] = 0;
  e[8] = a - 1;
  *(unsigned int *)(e + 2) = w;
  NotePool_InsertEntry(s);
  return 0;
}

extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int PartCtrl_ReadWord(unsigned int);

void SeqPos_AdvanceWithWrap(unsigned char a)
{
  unsigned int o;
  o = a + SEQ_DATA_OFFSET;
  SEQ_DATA_OFFSET = o;
  if (o > 0xff) {
    o -= 0x100;
    o += 5;
    SEQ_DATA_OFFSET = o;
    SEQ_DATA_BLOCK = PartCtrl_ReadWord(SEQ_DATA_BLOCK);
  }
}

extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int __near SEQ_ACTIVE_PARTS;
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern unsigned char __near ram_28ae;
extern unsigned char __near ram_28a6;
extern unsigned char Part_ReadVoiceByte(unsigned int, unsigned int);
extern void MidiChannel_ResetAndConfigure(void);
extern void SeqBuf_WriteNoteOffEntry(unsigned int);
extern void Chan_SetActiveBit(unsigned int, unsigned int);
extern void VoiceAlloc_ProcessAll(void);
extern void Part_SendVoiceOffAndCCEvents(unsigned int);
extern void Audio_CheckSubsystemReady(void);
extern void SeqBuf_Init(void);
extern void AccWrap_PositionClear(void);

void Part_DeactivateVoiceChannel(unsigned char a)
{
  int c;
  if (Part_ReadVoiceByte(0, a) == 0x0f) {
    ram_28ae &= ~0x80;
    MidiChannel_ResetAndConfigure();
  }
  c = a;
  if (SEQ_TRANSPORT_STATE & 0x04) {
    if (SEQ_TRACK_MASK != 0) {
      Part_SendVoiceOffAndCCEvents(c);
    } else {
      SEQ_ACTIVE_PARTS = 0;
      SeqBuf_WriteNoteOffEntry(0x32);
      Chan_SetActiveBit(a, 1);
      VoiceAlloc_ProcessAll();
      SEQ_TRACK_MASK = 0;
      Audio_CheckSubsystemReady();
      Audio_CheckSubsystemReady();
      SeqBuf_Init();
    }
    goto clear;
  }
  SEQ_ACTIVE_PARTS = SEQ_ACTIVE_PARTS & ~(1 << ((unsigned char)c - 1));
  if (SEQ_TRACK_MASK == 0) {
    SEQ_ACTIVE_PARTS = 0;
    DEMO_CONTROL_FLAGS &= ~0x80;
    SeqBuf_Init();
clear:
    ram_28a6 &= ~0x01;
    AccWrap_PositionClear();
  }
  Audio_CheckSubsystemReady();
}

extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned char __near CURRENT_TITLE;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned char __near ram_2524;
extern unsigned int __near ram_2520;
extern unsigned int __near ram_2838;
extern void SeqPlay_FindAndActivateVoice(unsigned int);
extern void Part_DeactivateChannel(unsigned int);
extern void SeqVoice_DeactivateAndReinit(unsigned int);
extern int Part_IsVoiceActive(unsigned int);
extern void SeqVoice_ActivateWithBarSync(unsigned int);
extern void NoteEditSy_SendModeScrollReset(void);
extern void SeqPlay_InitStartState(void);
extern void Accomp_ValidateAutoPlayChordVoice(void);

void SeqPlay_HandleChannelState(unsigned char a)
{
  unsigned int m, r;
  if (SEQ_TRANSPORT_STATE & 0x04) return;
  ram_2524 = 1;
  m = 1 << (a - 1);
  r = m & SEQ_REC_TRACKS;
  if (r == 0) {
    if (!(m & SEQ_TRACK_MASK)) SeqPlay_FindAndActivateVoice(a);
    else { Part_DeactivateChannel(a); SeqVoice_DeactivateAndReinit(a); }
  } else {
    SeqVoice_DeactivateAndReinit(a);
    if (Part_IsVoiceActive(a)) SeqVoice_ActivateWithBarSync(a);
    else Part_DeactivateChannel(a);
  }
  SEQ_RTMCFG &= ~0x08;
  if (CURRENT_TITLE != 0x87 && CURRENT_TITLE != 0x88) {
    if (!(SEQ_CYCLE_FLAGS & 0x02)) SEQ_START_MEASURE = 1;
    else {
      SEQ_START_MEASURE = ram_2520;
      if (SEQ_START_MEASURE != 1) SEQ_RTMCFG |= 0x08;
    }
  }
  NoteEditSy_SendModeScrollReset();
  SeqPlay_InitStartState();
  Accomp_ValidateAutoPlayChordVoice();
  ram_2838 = SEQ_TRACK_MASK;
}

/* ---- new ---- */

extern unsigned int __near ram_25a0;
extern unsigned char __near ram_25a2;
extern unsigned int __near ram_25a4;
extern unsigned char __near ram_25a6;
extern unsigned int __near ram_25a8;
extern unsigned char __near ram_25aa;
extern unsigned int __near ram_25b8;
extern unsigned int __near ram_25ba;
extern unsigned int __near ram_25bc;
extern unsigned int __near ram_25be;
extern unsigned char __near ram_25c2;
extern unsigned int __near ram_2598;
extern unsigned int __near ram_259a;
extern unsigned int __near ram_259c;
extern unsigned int __near ram_259e;
extern void SeqStep_HandleNoteOverflow(unsigned int);
extern unsigned char VoiceAlloc_TestBitHigh(void);
extern void SeqTiming_CompareAndUpdateState(void);

/* of the two candidate next events (position 0x25a4 / 0x25a6 and 0x25a8 / 0x25aa, 0xffff = none) takes the
   earlier one into 0x25a0 / 0x25a2 and moves the read position to its stream; L = 0 or 1 (which stream), 0xff
   when neither has an event */
unsigned char SeqEvt_SelectNearestTiming(void)
{
  unsigned int p, q;
  p = ram_25a4;
  if (p == 0xffff && ram_25a8 == 0xffff) {
    SeqStep_HandleNoteOverflow(ram_25c2);
    return 0xff;
  }
  q = ram_25a8;
  if (p == q && ram_25a6 == ram_25aa) goto equal;
  if (p < q || (p == q && ram_25a6 < ram_25aa)) {
    ram_25a0 = p;
    ram_25a2 = ram_25a6;
    ram_25ba = ram_25b8;
    ram_25b8 = ram_25bc;
    goto apply0;
  }
  ram_25a0 = q;
  ram_25a2 = ram_25aa;
  ram_25ba = ram_25b8;
  ram_25b8 = ram_25be;
  goto apply1;
equal:
  if (p == 0 && ram_25a6 == 0) goto second;
  if (VoiceAlloc_TestBitHigh() != 0x0f) goto first;
second:
  ram_25a0 = ram_25a8;
  ram_25a2 = ram_25aa;
  ram_25ba = ram_25b8;
  ram_25b8 = ram_25be;
apply0:
  SeqTiming_CompareAndUpdateState();
  SEQ_DATA_BLOCK = ram_2598;
  SEQ_DATA_OFFSET = ram_259c;
  return 0;
first:
  ram_25a0 = ram_25a4;
  ram_25a2 = ram_25a6;
  ram_25ba = ram_25b8;
  ram_25b8 = ram_25bc;
apply1:
  SeqTiming_CompareAndUpdateState();
  SEQ_DATA_BLOCK = ram_259a;
  SEQ_DATA_OFFSET = ram_259e;
  return 1;
}

extern void Rhythm_DispatchNoteAlloc(unsigned int, unsigned int *, unsigned char *);

/* runs the note-allocation dispatcher for a with a zeroed count and flag; returns the count */
unsigned int Rhythm_ComputeNoteAllocation(unsigned int a)
{
  unsigned char f;
  unsigned int r;
  r = 0;
  f = 0;
  Rhythm_DispatchNoteAlloc(a, &r, &f);
  return r;
}

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near ram_f218[];
extern unsigned int __near ram_f1f8[];
extern void Part_ValidateVoiceChannel(unsigned int);
extern unsigned char SeqData_ReadNextByte(void);

/* validates part a and moves the playback position to its start (block: word a-1 of 0xf1f8, at most 0x4d8;
   offset: byte a-1 of 0xf218, 5..0xff); the first event there must be a bar or end marker */
void Part_ValidateVoiceAndSetupSeq(unsigned char a)
{
  unsigned int o, b;
  unsigned char t;
  Part_ValidateVoiceChannel(a);
  if (SEQ_ERROR_CODE != 0) return;
  o = ram_f218[(unsigned char)(a - 1)];
  if (o < 5 || o > 0xff) goto bad;
  b = ram_f1f8[(unsigned char)(a - 1)];
  if (b > 0x4d8) { SEQ_ERROR_CODE = 10; return; }
  SEQ_DATA_BLOCK = b;
  SEQ_DATA_OFFSET = o;
  t = SeqData_ReadNextByte();
  if (t != 0x82 && t != 0x84) {
bad:
    SEQ_ERROR_CODE = 11;
    return;
  }
  SEQ_ERROR_CODE = 0;
}
