/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine_m234.c (2026-11-18-12-p6-r35)
   sha256 cc04abf6bd9183372ea4d401207ba7bbb922d5b7b56a23aa7e7eddfefd39244d (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void Rhythm_DispatchNoteAlloc(unsigned int, unsigned int *, unsigned char *);
unsigned int Rhythm_ComputeNoteAllocation(unsigned int a)
{
  unsigned int r;
  unsigned char f;
  r = 0;
  f = 0;
  Rhythm_DispatchNoteAlloc(a, &r, &f);
  return r;
}
