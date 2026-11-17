/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/note_voice_mapping_m298_xr.c (2026-11-16-68-p6-r12)
   sha256 470d2ac3f2e29c823fbcf47f0e2c72c696edd29d2931c2c99ee497d781e25f2d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern int SndParam_LookupReadOnly(long);
unsigned char Note_CheckTransposeRange(unsigned char a, unsigned char c)
{
  unsigned char r = 0;
  if (SndParam_LookupReadOnly(0xc0L) == 1) {
    if (c == 0x78) r = 1; else r = 0;
  } else {
    if ((a & 0xf0) == 0xf0) r = 1; else r = 0;
  }
  return r;
}
