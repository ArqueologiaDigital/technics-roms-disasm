/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/note_voice_mapping_xr.c (2026-11-16-55-p6-r10)
   sha256 7f9dc272f0ae7c42ec7e47f66d37f8670ad846663da684051feaa5787610a128 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
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
