/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_1a.c (2026-11-16-30-p6-r1)
   sha256 0d4602979081b19630e392a553f4b00a47f318a801919b0bcf1285f383535a70 (tar-sha256); compiled at -O3 -XS -Xr */
int SeqEvent_GetParamLength(unsigned char a)
{
  switch (a & 0xf0) { case 0x90: case 0xb0: case 0xc0: return 6; }
  switch (a) {
  case 0xd2: case 0x80: return 4;
  case 0xd0: case 0xd1: case 0xd3: case 0xa0: return 3;
  case 0x85: case 0x86: return 2;
  case 0x81: case 0x82: return 1;
  }
  return -1;
}
