/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5b.c (2026-11-16-45-p6-r9)
   sha256 f537949078528ed18dfc0b0b9e694946b4d167de54df22a7a21a6f0ca0494772 (tar-sha256); compiled at -O3 -Xr */
extern int SndParam_LookupViaEncode(int, int);
void SndParam_ApplyVoiceValue(unsigned char *r)
{
  unsigned char *q;
  int h;
  if (r[5] == 0x0f) {
    r[3] = r[2];
    r[4] = 0x78;
    return;
  }
  h = SndParam_LookupViaEncode(r[5], 0x20);
  q = r + 4;
  r[3] = r[2];
  if (h == 0x78) *q = 0x78; else *q = r[1];
}
