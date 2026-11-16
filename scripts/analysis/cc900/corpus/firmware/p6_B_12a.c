/* Phase 6, helper B, round 12, form a: two larger routines of v10's sequencer/sequencer_engine.s (-O3 -Xr).
   Stack structs are declared highest slot first (V4.23 gives the first-declared aggregate the highest slot); struct
   copies are written field by field (the firmware copies words through WA; V4.23 turns a struct assignment into
   ldiw). */

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

/* Copies the voice state of the track in 0x231c (its cursor at 0x23e0, bytes 2..7 and word 0 of its 8-byte
   record at 0x2338) into slot 19, the accompaniment's. -1 while 0x1d6a is set. */
int SeqAccomp_ReassignVoiceState(void)
{
  struct cur c;
  struct { unsigned int w; unsigned char x; } q;
  unsigned char buf[6];
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

/* Re-reads the track in 0x231a from its start cursor (0x2474 table), copying 0x1d78 bar events and then the rest of
   the bar to a new block chain; stores the new cursor at 0x23e0 and the track's index entry, and frees the old chain. */
void SeqPlay_ScanAndStoreChannelPos(void)
{
  unsigned char ev[4];
  struct cur s, r, d;
  unsigned int n, h;
  unsigned char t;
  n = 0;
  t = ram_231a;
  s.blk = ram_2474[(unsigned char)(t - 1)].c.blk;
  s.off = ram_2474[(unsigned char)(t - 1)].c.off;
  r.blk = s.blk;
  r.off = s.off;
  d.blk = s.blk;
  d.off = s.off;
  while (n < ram_1d78) {
    SeqPart_ReadNextEventByte(&r, ev);
    if (ev[0] == 0x81) { Part_CopyBytesToVoiceBlock(&d, ev, 1); n++; }
    else if (ev[0] == 0x82) break;
  }
  ram_23e0[(unsigned char)(t - 1)].blk = d.blk;
  ram_23e0[(unsigned char)(t - 1)].off = d.off;
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
