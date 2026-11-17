/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5a.c (2026-11-16-45-p6-r9)
   sha256 6f3782173ed786acb5b8f0b9571ad10fbd5c29c845f28fb8a50c793a4f9e1a23 (tar-sha256); compiled at -O3 -Xr */
extern int SndParam_LookupViaEncode(int, int);
extern void SndParam_FetchOscTableEntry(unsigned char *);
extern unsigned char __near CURRENT_TITLE;
unsigned char SelectTone_Continue_Prologue(unsigned char a)
{
  unsigned char b[6];
  if (CURRENT_TITLE == 246) {
    b[3] = SndParam_LookupViaEncode(0, 0);
    b[4] = SndParam_LookupViaEncode(0, 0x20);
    b[2] = 0;
    SndParam_FetchOscTableEntry(b);
    a = b[0] + 0xf0;
  }
  return a;
}
