/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/note_voice_mapping_m298_xr.c (2026-11-16-68-p6-r12)
   sha256 470d2ac3f2e29c823fbcf47f0e2c72c696edd29d2931c2c99ee497d781e25f2d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
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
