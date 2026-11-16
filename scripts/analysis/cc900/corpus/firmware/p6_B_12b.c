/* Phase 6, helper B, round 12, form b: the functions of p6_B_12a.c with struct assignments, for loops and the
   track index kept in an int. */

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
  unsigned char buf[6];
  unsigned int k;
  unsigned char t, i;
  if (ram_1d6a != 0) return -1;
  SEQ_CYCLE_FLAGS &= ~0x01;
  ram_22fc = 3;
  ram_1d92 = 0;
  ram_2316 = SEQ_ACTIVE_PARTS;
  t = ram_231c;
  if (t == 0xff) return 0;
  k = (unsigned char)(t - 1);
  c = ram_23e0[k];
  ram_23e0[19] = c;
  for (i = 0; i < 6; i++) buf[i] = ram_2338[(unsigned char)(t - 1)].b[i];
  for (i = 0; i < 6; i++) ram_2338[19].b[i] = buf[i];
  q.w = ram_2338[k].w;
  q.x = ram_2338[k].b[1];
  ram_2338[19].w = q.w;
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
  unsigned char ev[4];
  struct cur s, r, d;
  unsigned int n, h;
  unsigned char t;
  n = 0;
  t = ram_231a;
  s = ram_2474[(unsigned char)(t - 1)].c;
  r = s;
  d = s;
  for (; n < ram_1d78; ) {
    SeqPart_ReadNextEventByte(&r, ev);
    if (ev[0] == 0x81) { Part_CopyBytesToVoiceBlock(&d, ev, 1); n++; continue; }
    if (ev[0] == 0x82) break;
  }
  ram_23e0[(unsigned char)(t - 1)] = d;
  if (ev[0] != 0x82 && ev[0] != 0x84) {
    while (ev[0] != 0x82 && ev[0] != 0x84) {
      h = SeqPart_ReadNextEventByte(&r, ev);
      Part_CopyBytesToVoiceBlock(&d, ev, (unsigned char)h);
    }
  }
  Part_WriteWord_Indexed(0, t, d.blk);
  Part_WriteByte_Indexed(0, t, d.off);
  Part_CopyBytesToVoiceBlock(&d, ev, 1);
  h = PartCtrl_ReadWord(d.blk);
  if (h != 0xffff) {
    Part_StealAndReallocVoices(h);
    PartCtrl_WriteWord(d.blk, 0xffff);
  }
}
