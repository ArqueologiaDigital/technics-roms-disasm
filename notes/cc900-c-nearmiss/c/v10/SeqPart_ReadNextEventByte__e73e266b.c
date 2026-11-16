/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_B_8m234.c (2026-11-16-72-p6-r13)
   sha256 e73e266b5f46245381be6e0d9b7eaa0e4e36b433e1209e7db3409a4618392f2b (tar-sha256); compiled at -O3 -Xr */
/* Phase 6, helper B, round 8, module 234 of v10's sequencer/sequencer_engine.s (notes/cc900-phase6-2026-11-16/
   modules_v10.tsv): SeqPart_ReadNextEventByte with its calr callee PartCtrl_ReadWord defined in the same file, so
   that asm900 writes the call relative.  -O3 -Xr.
   Part control blocks: 256-byte records at 0xb0000, block n at 0xb0000 + (n - 1) * 0x100; word +3 = next block
   (0xffff ends the chain); event data from offset 5 to 0xff. */

extern unsigned char ram_b0000[];

unsigned int PartCtrl_ReadWord(unsigned int n)
{
  return *(unsigned int *)(0xb0000L + (((unsigned long)(n - 1) << 8) + 3));
}

/* Reads one whole event (status byte and up to seven data bytes) at the cursor c = {block, offset} into buf;
   returns the number of bytes, 1 for an end (0x82) or bar (0x84) marker, -1 for a bad status or the chain end. */
struct cur { unsigned int blk; unsigned int off; };

int SeqPart_ReadNextEventByte(struct cur *c, unsigned char *buf)
{
  unsigned char *base;
  unsigned int *po;
  unsigned char n, v;
  base = ram_b0000 + ((unsigned long)(c->blk - 1) << 8);
  po = &c->off;
  buf[0] = base[*po];
  n = 1;
  if (buf[0] == 0x82 || buf[0] == 0x84) return 1;
  if (*po == 0xff) {
    *po = 5;
    c->blk = PartCtrl_ReadWord(c->blk);
    if (c->blk == 0xffff) return -1;
    base = ram_b0000 + ((unsigned long)(c->blk - 1) << 8);
  } else (*po)++;
  if (!(buf[0] & 0x80)) return -1;
  do {
    po = &c->off;
    v = base[*po];
    buf[n] = v;
    if (v & 0x80) break;
    n++;
    if (*po == 0xff) {
      *po = 5;
      c->blk = PartCtrl_ReadWord(c->blk);
      if (c->blk == 0xffff) return -1;
      base = ram_b0000 + ((unsigned long)(c->blk - 1) << 8);
    } else (*po)++;
  } while (n < 8);
  return n;
}
