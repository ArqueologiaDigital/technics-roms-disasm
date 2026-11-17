/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m234.c (2026-11-16-92-p6-r18)
   sha256 fbb0b018cd527aa7866eb353aa9f9eacfb01ac784587d8707a5b566c830b2ddf (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char ram_b0000[];
unsigned int PartCtrl_ReadWord(unsigned int n)
{
  return *(unsigned int *)((unsigned long)ram_b0000 + (((unsigned long)(n - 1) << 8) + 3));
}
