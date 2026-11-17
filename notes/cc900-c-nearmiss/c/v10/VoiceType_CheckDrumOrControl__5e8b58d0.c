/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_9b.c (2026-11-16-87-p6-r15)
   sha256 5e8b58d00e7ea44f19f75c57696df9a15178cfdb7df2be5742c6f7750a660f72 (tar-sha256); compiled at -O3 -XS -Xr */
int VoiceType_CheckDrumOrControl(unsigned char a, unsigned char *p)
{
  unsigned char f = 0;
  if (p[0] == 0x82) return 0;
  if ((p[0] & 0xf0) == 0xc0) { if (p[2] == 0x48 && p[3] == 0) f = 1; }
  else if ((p[0] & 0xf0) == 0xb0 && p[2] == 0x48 && p[3] == 7) f = 1;
  if (a == 0x15 ? f == 1 : f == 0) return 0;
  return -1;
}
