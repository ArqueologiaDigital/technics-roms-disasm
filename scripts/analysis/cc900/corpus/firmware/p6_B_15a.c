/* Phase 6, helper B, round 15, form a: v10 sequencer/sequencer_engine.s (-O3 -Xr).  Refinements of run r19's
   close misses (the event buffer is 8 bytes and the 6-byte copy buffer 8: the firmware's frames are 4 bytes
   larger; the record index as an int; the copied byte through a local, lane_sub's spelling (a)) and
   SeqPart_ReplayForward, new. */

struct cur { unsigned int blk, off; };
struct rec8 { unsigned int w; unsigned char b[6]; };
struct cur8 { struct cur c; unsigned char pad[4]; };
extern struct cur __near ram_23e0[];
extern struct rec8 __near ram_2338[];
extern struct cur8 __near ram_2474[];
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
  unsigned int k, w;
  unsigned char t, i;
  if (ram_1d6a != 0) return -1;
  SEQ_CYCLE_FLAGS &= ~0x01;
  ram_22fc = 3;
  ram_1d92 = 0;
  w = SEQ_ACTIVE_PARTS;
  ram_2316 = w;
  t = ram_231c;
  if (t != 0xff) {
    k = (unsigned char)(t - 1);
    c.blk = ram_23e0[k].blk;
    c.off = ram_23e0[k].off;
    ram_23e0[19].blk = c.blk;
    ram_23e0[19].off = c.off;
    i = 0;
    do { buf[i] = ram_2338[(unsigned char)(t - 1)].b[i]; i++; } while (i < 6);
    i = 0;
    do { ram_2338[19].b[i] = buf[i]; i++; } while (i < 6);
    q.w = ram_2338[k].w;
    q.x = ram_2338[k].b[1];
    ram_2338[19].w = q.w;
  }
  return 0;
}

extern int SeqPart_ReadNextEventByte(struct cur *, unsigned char *);
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
  n = 0;
  t = ram_231a;
  s.blk = ram_2474[t - 1].c.blk;
  s.off = ram_2474[t - 1].c.off;
  r.blk = s.blk;
  r.off = s.off;
  d.blk = s.blk;
  d.off = s.off;
  while (n < ram_1d78) {
    SeqPart_ReadNextEventByte(&r, ev);
    if (ev[0] == 0x81) { Part_CopyBytesToVoiceBlock(&d, ev, 1); n++; }
    else if (ev[0] == 0x82) break;
  }
  ram_23e0[t - 1].blk = d.blk;
  ram_23e0[t - 1].off = d.off;
  if (ev[0] == 0x82 || ev[0] == 0x84) {
    Part_WriteWord_Indexed(0, t, d.blk);
    Part_WriteByte_Indexed(0, t, d.off);
    Part_CopyBytesToVoiceBlock(&d, ev, 1);
  } else {
    while (ev[0] != 0x82 && ev[0] != 0x84)
      Part_CopyBytesToVoiceBlock(&d, ev, (unsigned char)SeqPart_ReadNextEventByte(&r, ev));
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
extern unsigned char __near ram_2546[];
extern unsigned char __near ram_2576[];
extern unsigned char __near ram_2587;
extern unsigned int __near ram_2526[];
extern unsigned int __near ram_2556[];
extern unsigned int __near ram_258e;

void VoiceChan_PostStatusEvent(void)
{
  unsigned char v = ram_2587;
  ram_2546[SEQ_PART_LOOP] = v;
  ram_2526[SEQ_PART_LOOP] = ram_258e;
}

void SeqScan_StoreResultB(void)
{
  unsigned char v = ram_2587;
  ram_2576[SEQ_PART_LOOP] = v;
  ram_2556[SEQ_PART_LOOP] = ram_258e;
}

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQOP_SECONDARY_BLOCK;
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern unsigned int __near ram_265c;
extern unsigned int __near ram_265e;
extern unsigned long __near ram_25da;
extern void PartCtrl_WriteByte_ZeroExtended(unsigned int, unsigned int, unsigned int);
extern void PartCtrl_ReadWordWithBoundsCheck(unsigned int *, unsigned int *);

/* Writes 0x25da - 1 bar markers (0x81) and an end marker (0x82) from the secondary cursor (0x265c / 0x265e). */
void SeqPart_ReplayForward(void)
{
  unsigned long i;
  SEQ_ERROR_CODE = 0;
  SEQOP_SECONDARY_BLOCK = ram_265c;
  SEQOP_SECONDARY_OFFSET = ram_265e;
  ram_25da = ram_25da - 1;
  i = 0;
  while (ram_25da != i) {
    PartCtrl_WriteByte_ZeroExtended(SEQOP_SECONDARY_BLOCK, SEQOP_SECONDARY_OFFSET, 0x81);
    i++;
    PartCtrl_ReadWordWithBoundsCheck(&SEQOP_SECONDARY_BLOCK, &SEQOP_SECONDARY_OFFSET);
    if (SEQ_ERROR_CODE != 0) return;
  }
  PartCtrl_WriteByte_ZeroExtended(SEQOP_SECONDARY_BLOCK, SEQOP_SECONDARY_OFFSET, 0x82);
}
