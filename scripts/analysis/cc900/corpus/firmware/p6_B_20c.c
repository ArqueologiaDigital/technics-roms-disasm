/* Phase 6, helper B, round 20, form c (other C shapes of p6_B_20a.c): v10 sequencer/sequencer_engine.s.
   Here: the part index computed once and reused for the final store (ScanAndStore), a char index local for both
   stores (the StoreResult pair), the record pointer advanced in a second statement (SetupVoice), the mask
   update and tests spelled differently (the two new part routines), and WriteByteToBuf as integer arithmetic
   cast to a pointer (the idiom of the matched VoiceTable_ResolveReadAddr). */
/* cc900-module: Accomp_ValidateAutoPlayChordVoice Chan_SetActiveBit NotePool_InsertEntry Part_DeactivateChannel Part_IsVoiceActive Part_ReadVoiceByte Part_SendVoiceOffAndCCEvents SeqBuf_WriteNoteOffEntry SeqPlay_FindAndActivateVoice SeqPlay_InitStartState SeqVoice_ActivateWithBarSync SeqVoice_DeactivateAndReinit VoiceAlloc_ProcessAll */

struct cur { unsigned int blk, off; };
struct rec8 { unsigned int w; unsigned char b[6]; };
struct cur8 { struct cur c; unsigned char pad[4]; };

extern struct cur __near ram_23e0[];
extern struct rec8 __near ram_2338[];
extern struct cur8 __near ram_2474[];
extern unsigned char __near ram_2546[];
extern unsigned char __near ram_2576[];
extern unsigned int __near ram_2526[];
extern unsigned int __near ram_2556[];
extern unsigned char __near ram_1db6[];

#define CUR_23E0 ((struct cur *)ram_23e0)
#define REC_2338 ((struct rec8 *)ram_2338)
#define CUR8_2474 ((struct cur8 *)ram_2474)
#define WORD_2526 ((unsigned int *)ram_2526)
#define WORD_2556 ((unsigned int *)ram_2556)

extern unsigned char __near ram_231a;
extern unsigned int __near ram_1d78;

extern unsigned char SeqPart_ReadNextEventByte(struct cur *, unsigned char *);
extern void Part_CopyBytesToVoiceBlock(struct cur *, unsigned char *, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void Part_StealAndReallocVoices(unsigned int);

void SeqPlay_ScanAndStoreChannelPos(void)
{
  unsigned char ev[8];
  struct cur s, r, d;
  unsigned int n, h;
  unsigned int b0, b1;
  unsigned char t, i;
  n = 0;
  t = ram_231a;
  i = t - 1;
  s.blk = CUR8_2474[i].c.blk;
  s.off = CUR8_2474[i].c.off;
  r.blk = s.blk;
  r.off = s.off;
  d.blk = s.blk;
  d.off = s.off;
  while (n < ram_1d78) {
    SeqPart_ReadNextEventByte(&r, ev);
    if (ev[0] == 0x81) { Part_CopyBytesToVoiceBlock(&d, ev, 1); n++; }
    else if (ev[0] == 0x82) break;
  }
  b0 = d.blk;
  b1 = d.off;
  CUR_23E0[i].blk = b0;
  CUR_23E0[i].off = b1;
  if (ev[0] == 0x82 || ev[0] == 0x84) {
    Part_WriteWord_Indexed(0, t, d.blk);
    Part_WriteByte_Indexed(0, t, d.off);
    Part_CopyBytesToVoiceBlock(&d, ev, 1);
  } else {
    while (ev[0] != 0x82 && ev[0] != 0x84)
      Part_CopyBytesToVoiceBlock(&d, ev, SeqPart_ReadNextEventByte(&r, ev));
    Part_WriteWord_Indexed(0, t, d.blk);
    Part_WriteByte_Indexed(0, t, d.off);
    Part_CopyBytesToVoiceBlock(&d, ev, 1);
  }
  h = PartCtrl_ReadWord(d.blk);
  if (h != 0xffff) {
    Part_StealAndReallocVoices(h);
    PartCtrl_WriteWord(d.blk, 0xffff);
  }
}

extern volatile unsigned char __near SEQ_PART_LOOP;
extern volatile unsigned char __near ram_2587;
extern unsigned int __near ram_258e;

void VoiceChan_PostStatusEvent(void)
{
  unsigned char i;
  i = SEQ_PART_LOOP;
  ram_2546[i] = ram_2587;
  i = SEQ_PART_LOOP;
  WORD_2526[i] = ram_258e;
}

void SeqScan_StoreResultB(void)
{
  unsigned char i;
  i = SEQ_PART_LOOP;
  ram_2576[i] = ram_2587;
  i = SEQ_PART_LOOP;
  WORD_2556[i] = ram_258e;
}

extern void SeqData_SetErrorCode(unsigned char);
extern unsigned char __near ram_1db4;
extern void NoteMap_RemoveHeadEntry(unsigned int);
extern void NotePool_InsertEntry(unsigned char);

unsigned char SeqNote_SetupVoice(unsigned char a, unsigned char *p)
{
  unsigned int w;
  unsigned char *e;
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
  e = (unsigned char *)ram_1db6;
  e += (int)s * 9;
  e[4] = p[0];
  e[5] = n;
  e[6] = p[2];
  e[7] = 0;
  e[8] = a - 1;
  *(unsigned int *)(e + 2) = w;
  NotePool_InsertEntry(s);
  return 0;
}

/* ---- new ---- */

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
  if (Part_ReadVoiceByte(0, a) == 0x0f) {
    ram_28ae &= ~0x80;
    MidiChannel_ResetAndConfigure();
  }
  if (SEQ_TRANSPORT_STATE & 0x04) {
    if (SEQ_TRACK_MASK != 0) {
      Part_SendVoiceOffAndCCEvents(a);
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
  SEQ_ACTIVE_PARTS = SEQ_ACTIVE_PARTS & ~(1 << (a - 1));
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
  unsigned int m;
  if (SEQ_TRANSPORT_STATE & 0x04) return;
  ram_2524 = 1;
  m = 1 << (a - 1);
  if (!(m & SEQ_REC_TRACKS)) {
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

void PartCtrl_WriteByteToBuf(unsigned int b, unsigned char o, unsigned char v)
{
  unsigned long r;
  r = (unsigned long)(b - 1) << 8;
  r += o;
  r += 0xb0000;
  *(unsigned char *)r = v;
}
