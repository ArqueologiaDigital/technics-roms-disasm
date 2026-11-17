/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5b.c (2026-11-16-45-p6-r9)
   sha256 f537949078528ed18dfc0b0b9e694946b4d167de54df22a7a21a6f0ca0494772 (tar-sha256); compiled at -Xr */
extern int SndParam_LookupReadOnly(long);
unsigned char Note_CheckTransposeRange(unsigned char a, unsigned char c)
{
  if (SndParam_LookupReadOnly(0xc0L) == 1) {
    if (c == 0x78) return 1;
    return 0;
  }
  if ((a & 0xf0) == 0xf0) return 1;
  return 0;
}
