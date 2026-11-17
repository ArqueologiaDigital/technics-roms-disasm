/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_1b.c (2026-11-16-30-p6-r1)
   sha256 bd6e4557c8e04a2edcf7c0a4f18652e01cf59f735fd3362c0cbe758f01080833 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned int __near SEQ_FREE_BLOCKS;
unsigned char Seq_ComputePercentClamped99(void)
{
  unsigned int d = 0x4d8, n = SEQ_FREE_BLOCKS;
  unsigned char r;
  while (n > 0x258) { d >>= 1; n >>= 1; }
  r = n * 100 / d;
  if (r == 100) return 99;
  return r;
}
