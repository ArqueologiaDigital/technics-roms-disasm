/* Phase 6, helper B, round 9, module 234 of v10's sequencer/sequencer_engine.s (-O3 -Xr):
   PartCtrl_ReadWord and SeqPart_ReadNextEventByte, which calls it with calr.
   Part control blocks: 256-byte records at 0xb0000, block n at 0xb0000 + (n - 1) * 0x100; word +3 = next block
   (0xffff ends the chain); event data from offset 5 to 0xff. */
/* cc900-module: PartCtrl_ReadWord */

extern unsigned char ram_b0000[];

/* the base is loaded as an immediate (ld xbc,0xb0000) after the offset: an integer address */
unsigned int PartCtrl_ReadWord(unsigned int n)
{
  return *(unsigned int *)((unsigned long)ram_b0000 + (((unsigned long)(n - 1) << 8) + 3));
}

struct cur { unsigned int blk; unsigned int off; };

/* Reads one whole event (status byte and up to seven data bytes) at the cursor c = {block, offset} into buf;
   returns the number of bytes, 1 for an end (0x82) or bar (0x84) marker, -1 for a bad status or the chain end.
   The offset is read once into a register for the test and the increment. */
int SeqPart_ReadNextEventByte(struct cur *c, unsigned char *buf)
{
  unsigned char *base;
  unsigned int *po;
  unsigned int w;
  unsigned char n, v;
  base = ram_b0000 + ((unsigned long)(c->blk - 1) << 8);
  po = &c->off;
  buf[0] = base[*po];
  n = 1;
  if (buf[0] == 0x82 || buf[0] == 0x84) return 1;
  w = *po;
  if (w == 0xff) {
    *po = 5;
    c->blk = PartCtrl_ReadWord(c->blk);
    if (c->blk == 0xffff) return -1;
    base = ram_b0000 + ((unsigned long)(c->blk - 1) << 8);
  } else *po = w + 1;
  if (!(buf[0] & 0x80)) return -1;
  do {
    po = &c->off;
    v = base[*po];
    buf[n] = v;
    if (v & 0x80) break;
    n++;
    w = *po;
    if (w == 0xff) {
      *po = 5;
      c->blk = PartCtrl_ReadWord(c->blk);
      if (c->blk == 0xffff) return -1;
      base = ram_b0000 + ((unsigned long)(c->blk - 1) << 8);
    } else *po = w + 1;
  } while (n < 8);
  return n;
}
