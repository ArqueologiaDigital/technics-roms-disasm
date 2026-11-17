/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5a.c (2026-11-16-45-p6-r9)
   sha256 6f3782173ed786acb5b8f0b9571ad10fbd5c29c845f28fb8a50c793a4f9e1a23 (tar-sha256); compiled at -Xr */
extern int SndParam_LookupViaEncode(int, int);
void SndParam_ApplyVoiceValue(unsigned char *r)
{
  unsigned char *q;
  if (r[5] != 0x0f) {
    int h = SndParam_LookupViaEncode(r[5], 0x20);
    q = r + 4;
    r[3] = r[2];
    if (h == 0x78) *q = 0x78; else *q = r[1];
  } else {
    r[3] = r[2];
    r[4] = 0x78;
  }
}
