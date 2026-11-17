/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_20c.c (2026-11-17-16-p6-r31)
   sha256 7d3e44df5e3fc9cd5496e97dca74919be33076be617222a25535753dca33ad9e (tar-sha256); compiled at -O3 -Xr */
struct cur { unsigned int blk, off; };
struct cur8 { struct cur c; unsigned char pad[4]; };
extern struct cur __near ram_23e0[];
extern struct cur8 __near ram_2474[];
#define CUR_23E0 ((struct cur *)ram_23e0)
#define CUR8_2474 ((struct cur8 *)ram_2474)
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
