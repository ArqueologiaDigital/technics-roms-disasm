/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/note_voice_mapping.c (2026-11-16-55-p6-r10)
   sha256 ae6ea6f7a0e36a5f953acf483ff3903bae4bc1f974cfac28ea5280a3680b6353 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
