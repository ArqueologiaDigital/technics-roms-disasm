/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_17b.c (2026-11-16-123-p6-r25)
   sha256 72cedcc8ffc19dabf54723396bbfc6ab65a815ac80d5edf091bccbe30696935b (tar-sha256); compiled at -O3 -Xr */
struct cur { unsigned int blk, off; };
struct cur8 { struct cur c; unsigned char pad[4]; };
extern struct cur __near ram_23e0[];
extern struct cur8 __near ram_2474[];
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
