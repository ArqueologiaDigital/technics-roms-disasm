/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/note_voice_mapping.c (2026-11-16-55-p6-r10)
   sha256 46ef0efe4605efd77869d316d28ff905ba2b2cec5da8b130f11b506d691fd665 (tar-sha256); compiled at -Xr
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
