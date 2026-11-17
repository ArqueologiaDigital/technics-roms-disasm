/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_11b.c (2026-11-16-92-p6-r18)
   sha256 d81ab2ed510917a4554387354931a99fcc0a113f9672b322cfb51e6682af2006 (tar-sha256); compiled at -O3 -XS -Xr */
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
