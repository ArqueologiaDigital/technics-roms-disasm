/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

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
