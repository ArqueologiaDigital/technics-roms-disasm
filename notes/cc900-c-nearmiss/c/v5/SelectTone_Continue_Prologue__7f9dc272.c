/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/note_voice_mapping_xr.c (2026-11-16-55-p6-r10)
   sha256 7f9dc272f0ae7c42ec7e47f66d37f8670ad846663da684051feaa5787610a128 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
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
