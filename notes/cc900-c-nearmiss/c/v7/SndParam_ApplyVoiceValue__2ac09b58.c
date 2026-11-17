/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/note_voice_mapping.c (2026-11-16-55-p6-r10)
   sha256 2ac09b58c86184e8cf24523962a18d4592e78ca191a229cd1a3daa6760f9782a (tar-sha256); compiled at -Xr
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
