/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5a.c (2026-11-16-45-p6-r9)
   sha256 6f3782173ed786acb5b8f0b9571ad10fbd5c29c845f28fb8a50c793a4f9e1a23 (tar-sha256); compiled at -O3 -Xr */
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
