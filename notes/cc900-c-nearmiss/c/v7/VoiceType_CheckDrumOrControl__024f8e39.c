/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m233.c (2026-11-16-111-p6-r22-staged)
   sha256 024f8e397b4537bcd7edca5e778bbfd107df7d008d83a1b6d67f735fa2aab499 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
int VoiceType_CheckDrumOrControl(unsigned char a, unsigned char *p)
{
  unsigned char f = 0;
  if (p[0] == 0x82) return 0;
  if ((p[0] & 0xf0) == 0xc0) { if (p[2] == 0x48 && p[3] == 0) f = 1; }
  else if ((p[0] & 0xf0) == 0xb0 && p[2] == 0x48 && p[3] == 7) f = 1;
  if (a == 0x15) {
    if (f != 1) return -1;
  } else if (f != 0) return -1;
  return 0;
}
