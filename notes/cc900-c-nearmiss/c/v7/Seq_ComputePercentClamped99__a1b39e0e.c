/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine.c (2026-11-16-33-p6-r2)
   sha256 a1b39e0eed457b8cec3de76aac5f52cd3fb2d00338cbbd89325bb8f84b4a4d13 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_FREE_BLOCKS;
unsigned char Seq_ComputePercentClamped99(void)
{
  unsigned int d = 0x4d8, n = SEQ_FREE_BLOCKS;
  unsigned char r;
  if (n > 0x258) do { d >>= 1; n >>= 1; } while (n > 0x258);
  r = n * 100 / d;
  if (r == 100) r = 99;
  return r;
}
