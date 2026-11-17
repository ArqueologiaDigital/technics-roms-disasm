/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/note_voice_mapping_m303.c (2026-11-16-68-p6-r12)
   sha256 9bd437831e355a96b5b72e39909bb47171152b15a53c8b04207a3d76fd6feaa9 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
