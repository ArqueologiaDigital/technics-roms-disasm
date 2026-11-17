/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5b.c (2026-11-16-45-p6-r9)
   sha256 f537949078528ed18dfc0b0b9e694946b4d167de54df22a7a21a6f0ca0494772 (tar-sha256); compiled at -Xr */
extern int SndParam_LookupViaEncode(int, int);
extern void SndParam_FetchOscTableEntry(unsigned char *);
extern unsigned char __near CURRENT_TITLE;
unsigned char SelectTone_Continue_Prologue(unsigned char a)
{
  unsigned char b[6];
  if (CURRENT_TITLE != 246) return a;
  b[3] = SndParam_LookupViaEncode(0, 0);
  b[4] = SndParam_LookupViaEncode(0, 0x20);
  b[2] = 0;
  SndParam_FetchOscTableEntry(b);
  return b[0] + 0xf0;
}
