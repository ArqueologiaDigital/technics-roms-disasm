/* Phase 6, helper B, round 19, form c (other C shapes of p6_B_19a.c): v10 sequencer/sequencer_engine.s.
   Here: for copy loops (ReassignVoiceState), the first index taken from the global, (unsigned char)(ram_231a - 1)
   (ScanAndStore: the ROM keeps A after storing t, as if the index were computed from the loaded value), the word
   table through a cast with an (int) index (the two StoreResult routines), `!(s & 0x8000L)`
   (CheckRepeatAndReactivate), the row indexed with (int)s (SetupVoice), and AllocBuffersAndInit's repeat test
   written positive (if/else swapped). */
/* cc900-module: NotePool_InsertEntry SeqBuf_AllocNextSlot SeqBuf_AllocNextSlotAdjusted SeqPlay_ReactivatePartsAndResume SeqPlay_ResetStartState */

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
#define NOTE9_1DB6 ((unsigned char (*)[9])ram_1db6)

extern unsigned char __near ram_1d6a;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned char __near ram_22fc;
extern unsigned char __near ram_1d92;
extern unsigned int __near ram_2316;
extern unsigned int __near SEQ_ACTIVE_PARTS;
extern unsigned char __near ram_231c;
extern unsigned char __near ram_231a;
extern unsigned int __near ram_1d78;

int SeqAccomp_ReassignVoiceState(void)
{
  struct cur c;
  struct { unsigned int w; unsigned char x; } q;
  unsigned char buf[8];
  unsigned int w;
  unsigned char t, i;
  if (ram_1d6a != 0) return -1;
  SEQ_CYCLE_FLAGS &= ~0x01;
  ram_22fc = 3;
  ram_1d92 = 0;
  w = SEQ_ACTIVE_PARTS;
  ram_2316 = w;
  t = ram_231c;
  if (t != 0xff) {
    c.blk = CUR_23E0[(unsigned char)(t - 1)].blk;
    c.off = CUR_23E0[(unsigned char)(t - 1)].off;
    CUR_23E0[19].blk = c.blk;
    CUR_23E0[19].off = c.off;
    for (i = 0; i < 6; i++) buf[i] = REC_2338[(unsigned char)(t - 1)].b[i];
    for (i = 0; i < 6; i++) REC_2338[19].b[i] = buf[i];
    q.w = REC_2338[(unsigned char)(t - 1)].w;
    q.x = REC_2338[(unsigned char)(t - 1)].b[1];
    REC_2338[19].w = q.w;
  }
  return 0;
}

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
  unsigned char t;
  n = 0;
  t = ram_231a;
  s.blk = CUR8_2474[(unsigned char)(ram_231a - 1)].c.blk;
  s.off = CUR8_2474[(unsigned char)(ram_231a - 1)].c.off;
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
  CUR_23E0[(unsigned char)(t - 1)].blk = b0;
  CUR_23E0[(unsigned char)(t - 1)].off = b1;
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
  ram_2546[SEQ_PART_LOOP] = ram_2587;
  WORD_2526[(int)SEQ_PART_LOOP] = ram_258e;
}

void SeqScan_StoreResultB(void)
{
  ram_2576[SEQ_PART_LOOP] = ram_2587;
  WORD_2556[(int)SEQ_PART_LOOP] = ram_258e;
}

extern void SeqData_SetErrorCode(unsigned char);

extern unsigned char __near SEQ_PLAY_FLAGS;
extern unsigned char __near SEQ_SONG_RECORD[];
extern unsigned int __near SEQ_BEAT_COUNT;
extern unsigned int __near SEQ_PUNCH_IN_MEASURE;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near SEQ_RECORDED_TRACKS;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int __near ram_2959;
extern void SeqPlay_ReactivatePartsAndResume(void);

void SeqPlay_CheckRepeatAndReactivate(void)
{
  unsigned int c, s, p, m;
  if (!(SEQ_PLAY_FLAGS & 0x01)) return;
  if (!(SEQ_SONG_RECORD[188] & 0x01)) return;
  c = SEQ_BEAT_COUNT;
  p = SEQ_PUNCH_IN_MEASURE;
  s = SEQ_START_MEASURE;
  if (s == p) {
    ram_2959 = c;
    m = SEQ_REC_TRACKS & SEQ_ACTIVE_PARTS;
    SEQ_RECORDED_TRACKS = m;
  } else {
    if (p != 1) return;
    if (!(s & 0x8000L)) return;
    ram_2959 = c;
    m = SEQ_REC_TRACKS & SEQ_ACTIVE_PARTS;
    SEQ_RECORDED_TRACKS = m;
  }
  SEQ_TRACK_MASK &= ~m;
  SeqPlay_ReactivatePartsAndResume();
}

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
  e = NOTE9_1DB6[(int)s];
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

extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near SEQ_BEAT_TICK;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned int __near ram_2328;
extern unsigned int __near ram_232a;
extern unsigned int __near ram_251c;
extern unsigned int __near ram_251e;
extern unsigned int __near ram_2520;
extern unsigned int __near ram_2522;
extern unsigned int SeqBuf_AllocNextSlot(unsigned int);
extern unsigned int SeqBuf_AllocNextSlotAdjusted(unsigned int);
extern void SeqPlay_InitializePlayback(void);
extern unsigned char SeqAcc_InitPlaybackState(void);
extern void SeqPlay_ResetStartState(void);

void SeqPlay_AllocBuffersAndInit(void)
{
  unsigned char c;
  unsigned int w, h;
  c = CURRENT_TITLE;
  if (c == 0x85 || c == 0x86) {
    if (SEQ_CYCLE_FLAGS & 0x02) {
      h = SeqBuf_AllocNextSlot(ram_2520);
      ram_2328 = h;
      SEQ_BEAT_COUNT = h;
      SEQ_BEAT_TICK = 0;
      if (h != 0) SEQ_RTMCFG |= 0x08;
      else SEQ_RTMCFG &= ~0x08;
      ram_232a = SeqBuf_AllocNextSlotAdjusted(ram_2522);
    } else {
      ram_2328 = 0;
      SEQ_BEAT_COUNT = 0;
      SEQ_BEAT_TICK = 0;
      SEQ_RTMCFG &= ~0x08;
    }
    goto init;
  }
  w = SEQ_START_MEASURE;
  if (c == 0x87 || c == 0x88) {
    SEQ_BEAT_COUNT = SeqBuf_AllocNextSlot(w);
    SEQ_BEAT_TICK = 0;
init:
    SeqPlay_InitializePlayback();
  } else {
    if (SEQ_RTMCFG & 0x08) {
      SEQ_BEAT_COUNT = SeqBuf_AllocNextSlot(w);
      SEQ_BEAT_TICK = 0;
    }
    if (SEQ_CYCLE_FLAGS & 0x01) {
      ram_2328 = SeqBuf_AllocNextSlot(ram_251c);
      ram_232a = SeqBuf_AllocNextSlotAdjusted(ram_251e);
    }
    SeqAcc_InitPlaybackState();
  }
  SeqPlay_ResetStartState();
}
