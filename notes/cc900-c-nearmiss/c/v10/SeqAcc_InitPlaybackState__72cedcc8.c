/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_B_17b.c (2026-11-16-123-p6-r25)
   sha256 72cedcc8ffc19dabf54723396bbfc6ab65a815ac80d5edf091bccbe30696935b (tar-sha256); compiled at -O3 -Xr */
/* Phase 6, helper B, round 17, form b (other C shapes of p6_B_17a.c): v10 sequencer/sequencer_engine.s (-O3 -Xr).
   The tables are __near extern arrays reached through plain pointer locals (form a casts them instead); unsigned k
   with member-wise copies and do-while loops (ReassignVoiceState), member-wise stores (ScanAndStore), a plain for
   loop (ReadPartDataBlock), plain returns (InitPlaybackState), a widened test (CheckRepeatAndReactivate). */
/* cc900-module: FileIO_SeekAndRead16BitValue NotePool_InsertEntry SeqAcc_InitPlayback_FreshStart SeqPlay_CheckDrumPartAndClearCounters SeqPlay_ProcessChannelsAndDrum SeqPlay_ReactivatePartsAndResume SeqPlay_RestartWithVoiceConfig */

struct cur { unsigned int blk, off; };
struct rec8 { unsigned int w; unsigned char b[6]; };
struct cur8 { struct cur c; unsigned char pad[4]; };

extern struct cur __near ram_23e0[];
extern struct rec8 __near ram_2338[];
extern struct cur8 __near ram_2474[];
extern unsigned int __near ram_29ce[];
extern unsigned char __near ram_2546[];
extern unsigned char __near ram_2576[];
extern unsigned int __near ram_2526[];
extern unsigned int __near ram_2556[];
extern unsigned char __near ram_1db6[];

extern unsigned char __near ram_1d6a;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned char __near ram_22fc;
extern unsigned char __near ram_1d92;
extern unsigned int __near ram_2316;
extern unsigned int __near ram_2314;
extern unsigned int __near SEQ_ACTIVE_PARTS;
extern unsigned char __near ram_231c;
extern unsigned char __near ram_231e;
extern unsigned char __near ram_2320;
extern unsigned char __near ram_2322;
extern unsigned char __near ram_2324;
extern unsigned char __near ram_231a;
extern unsigned int __near ram_1d78;

int SeqAccomp_ReassignVoiceState(void)
{
  struct cur c;
  struct { unsigned int w; unsigned char x; } q;
  unsigned char buf[8];
  unsigned int k;
  unsigned char t, i;
  struct cur *pc;
  struct rec8 *pr;
  if (ram_1d6a != 0) return -1;
  SEQ_CYCLE_FLAGS &= ~0x01;
  ram_22fc = 3;
  ram_1d92 = 0;
  ram_2316 = SEQ_ACTIVE_PARTS;
  t = ram_231c;
  if (t != 0xff) {
    k = (unsigned char)(t - 1);
    pc = ram_23e0;
    c.blk = pc[k].blk;
    c.off = pc[k].off;
    pc[19].blk = c.blk;
    pc[19].off = c.off;
    pr = ram_2338;
    i = 0;
    do { buf[i] = pr[(unsigned char)(t - 1)].b[i]; i++; } while (i < 6);
    i = 0;
    do { pr[19].b[i] = buf[i]; i++; } while (i < 6);
    q.w = pr[k].w;
    q.x = pr[k].b[1];
    pr[19].w = q.w;
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
  unsigned char t;
  struct cur8 *src;
  struct cur *dst;
  n = 0;
  t = ram_231a;
  src = ram_2474;
  s = src[(unsigned char)(t - 1)].c;
  r = s;
  d = s;
  while (n < ram_1d78) {
    SeqPart_ReadNextEventByte(&r, ev);
    if (ev[0] == 0x81) { Part_CopyBytesToVoiceBlock(&d, ev, 1); n++; }
    else if (ev[0] == 0x82) break;
  }
  dst = ram_23e0;
  dst[(unsigned char)(t - 1)].blk = d.blk;
  dst[(unsigned char)(t - 1)].off = d.off;
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

extern unsigned char __near SEQ_PART_LOOP;
extern volatile unsigned char __near ram_2587;
extern unsigned int __near ram_258e;

void VoiceChan_PostStatusEvent(void)
{
  unsigned char *b;
  unsigned int *w;
  b = ram_2546;
  b[SEQ_PART_LOOP] = ram_2587;
  w = ram_2526;
  w[SEQ_PART_LOOP] = ram_258e;
}

void SeqScan_StoreResultB(void)
{
  unsigned char *b;
  unsigned int *w;
  b = ram_2576;
  b[SEQ_PART_LOOP] = ram_2587;
  w = ram_2556;
  w[SEQ_PART_LOOP] = ram_258e;
}

extern long FileIO_SeekAndRead16BitValue(unsigned long, unsigned int);
extern void SeqData_SetErrorCode(unsigned char);

long SeqLoad_ReadPartDataBlock(unsigned char a)
{
  unsigned long pos;
  unsigned int i, sum;
  long r;
  unsigned int *t;
  t = ram_29ce;
  if (t[a] == 0) return 0;
  pos = 0x800;
  sum = 0;
  for (i = 0; i < a; i++) {
    pos += (unsigned long)t[i] << 8;
    sum += t[i];
  }
  pos += 1;
  for (i = 1; i < ram_29ce[a]; i++) {
    if ((r = FileIO_SeekAndRead16BitValue(pos, sum + i - 1)) != 0) { SeqData_SetErrorCode(200); return r; }
    if ((r = FileIO_SeekAndRead16BitValue(pos + 2, sum + i + 1)) != 0) { SeqData_SetErrorCode(201); return r; }
    pos += 256;
  }
  if ((r = FileIO_SeekAndRead16BitValue(pos, sum + i - 1)) != 0) { SeqData_SetErrorCode(202); return r; }
  if ((r = FileIO_SeekAndRead16BitValue(pos + 2, 0xffff)) != 0) { SeqData_SetErrorCode(203); return r; }
  return r;
}

/* ---- new in round 16, re-sent ---- */

extern unsigned char __near ACTIVE_TITLE;
extern unsigned long __near SEQ_SCREEN_OBJECT;
extern void ApDeliveryEvent(long, long, long);

void SeqAccomp_SendStopNotify(void)
{
  unsigned char t = ACTIVE_TITLE;
  if (t == 0x85 || t == 0x87)
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, 0x1c0000fL, 2L);
}

extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned char __near ram_45b;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near ACC_RUN_FLAGS;
extern unsigned char __near ram_28ac;
extern unsigned char __near SEQ_CHORD_FROM_SONG;
extern void SeqNotePool_Init(unsigned int);
extern unsigned char SeqPlay_CheckRepeatActive(void);
extern unsigned char Part_FindVoiceByByte(unsigned int, unsigned int);
extern void BitMapOut_PrepareAndDisplay(void);
extern void BitMapOut_PrepareAndDisplaySimple(void);
extern void SeqAcc_InitPlayback_FreshStart(void);
extern void SeqPlay_RestartWithVoiceConfig(void);
extern void SeqPlay_CheckDrumPartAndClearCounters(void);
extern void SeqPlay_ResetStartState(void);

unsigned char SeqAcc_InitPlaybackState(void)
{
  unsigned char f;
  SEQ_CONTROL_FLAGS &= ~0x20;
  SeqNotePool_Init(0x32);
  ram_45b &= ~0x01;
  ram_1d92 = SeqPlay_CheckRepeatActive();
  if (SEQ_TRACK_MASK == 0) {
    if (SEQ_REC_TRACKS != 0) goto clear;
    f = SEQ_RTMCFG;
    f &= ~0x01;
    f |= 0x02;
    SEQ_RTMCFG = f;
    goto state0;
  }
  if (ACC_RUN_FLAGS & 0x02) {
    SEQ_CONTROL_FLAGS |= 0x10;
    return 0;
  }
  ram_231c = Part_FindVoiceByByte(0, 0x0d);
  ram_231e = Part_FindVoiceByByte(0, 0x10);
  ram_2320 = Part_FindVoiceByByte(0, 0x0c);
  ram_2322 = Part_FindVoiceByByte(0, 0x0e);
  ram_2324 = Part_FindVoiceByByte(0, 0x0f);
  BitMapOut_PrepareAndDisplay();
  BitMapOut_PrepareAndDisplaySimple();
  ram_28ac |= 0x10;
  if ((SEQ_RTMCFG & 0x08) == 0) SeqAcc_InitPlayback_FreshStart();
  else SeqPlay_RestartWithVoiceConfig();
  ram_28ac &= ~0x10;
  if (ram_2316 != 0) {
    SeqPlay_CheckDrumPartAndClearCounters();
    if (SEQ_REC_TRACKS == 0) {
      if (ram_1d92 != 0) ram_22fc = 4;
      else ram_22fc = 1;
    }
    SeqPlay_ResetStartState();
    return 0;
  }
  if (SEQ_REC_TRACKS == 0) {
state0:
    ram_22fc = 0;
  }
clear:
  SEQ_CHORD_FROM_SONG = 0;
  SeqPlay_ResetStartState();
  return 0;
}

extern unsigned char __near ram_2862;
extern unsigned char __near ram_2864;
extern unsigned char __near ram_2866;
extern void SeqPlay_ProcessChannelsAndDrum(void);

void SeqPlay_CheckDrumPartAndClearCounters(void)
{
  unsigned char t = ram_231c;
  unsigned int m;
  if (t != 0xff) {
    m = 1 << (t - 1);
    if ((SEQ_TRACK_MASK & m) != 0 || (ram_2314 & m) != 0) ram_28ac |= 0x40;
  }
  ram_1d6a = 0;
  ram_2862 = 0;
  ram_2864 = 0;
  ram_2866 = 0;
  SeqPlay_ProcessChannelsAndDrum();
}

extern unsigned char __near SEQ_PLAY_FLAGS;
extern unsigned char __near SEQ_SONG_RECORD[];
extern unsigned int __near SEQ_BEAT_COUNT;
extern unsigned int __near SEQ_PUNCH_IN_MEASURE;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near SEQ_RECORDED_TRACKS;
extern unsigned int __near ram_2959;
extern void SeqPlay_ReactivatePartsAndResume(void);

void SeqPlay_CheckRepeatAndReactivate(void)
{
  unsigned int c, p, s, m;
  if ((SEQ_PLAY_FLAGS & 0x01) == 0) return;
  if ((SEQ_SONG_RECORD[188] & 0x01) == 0) return;
  c = SEQ_BEAT_COUNT;
  p = SEQ_PUNCH_IN_MEASURE;
  s = SEQ_START_MEASURE;
  if (s == p) {
    ram_2959 = c;
    m = SEQ_REC_TRACKS & SEQ_ACTIVE_PARTS;
    SEQ_RECORDED_TRACKS = m;
  } else {
    if (p != 1) return;
    if ((long)s >= 0x8000L) {
      ram_2959 = c;
      m = SEQ_REC_TRACKS & SEQ_ACTIVE_PARTS;
      SEQ_RECORDED_TRACKS = m;
    } else return;
  }
  SEQ_TRACK_MASK &= ~m;
  SeqPlay_ReactivatePartsAndResume();
}

extern unsigned char __near ram_1db4;
extern void NoteMap_RemoveHeadEntry(unsigned int);
extern void NotePool_InsertEntry(unsigned char);

unsigned char SeqNote_SetupVoice(unsigned char a, unsigned char *p)
{
  unsigned char s, n;
  unsigned int w;
  struct rec8 *pr;
  unsigned char *e;
  s = ram_1db4;
  if (s == 0xff) return 1;
  if (a == 0) SeqData_SetErrorCode(0x0d);
  if (s >= 0x40) SeqData_SetErrorCode(0x0e);
  NoteMap_RemoveHeadEntry(s);
  pr = ram_2338;
  w = pr[(unsigned char)(a - 1)].w;
  n = pr[(unsigned char)(a - 1)].b[1];
  n += p[4];
  if (n >= 0x60) { n -= 0x60; w++; }
  w += p[5];
  if (a == 0x11) a = ram_231a;
  if (n > 0x60) SeqData_SetErrorCode(0x0f);
  e = ram_1db6;
  e += s * 9;
  e[4] = p[0];
  e[5] = n;
  e[6] = p[2];
  e[7] = 0;
  e[8] = a - 1;
  *(unsigned int *)(e + 2) = w;
  NotePool_InsertEntry(s);
  return 0;
}
