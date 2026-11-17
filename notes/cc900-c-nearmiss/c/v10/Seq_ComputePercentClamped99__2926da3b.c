/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine.c (2026-11-16-33-p6-r2)
   sha256 2926da3b9eb2de72d3e3c34376ec42ff12abeaddc7d637ca69c313362dcb672d (tar-sha256); compiled at -O3 -XS -Xr
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
