/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_4a.c (2026-11-16-40-p6-r8)
   sha256 51f33f7d2a542dcabaa0b35f2dc5bf07089f5d28b53e49e44f8cfe457d787e3c (tar-sha256); compiled at -O3 -XS -Xr */
extern void sendCOMM(int, int);
extern unsigned char __near ram_e197;
extern unsigned char __near ram_e2cc[];
unsigned char SubCPU_RequestShortSoundName(unsigned char a, unsigned char c)
{
  unsigned char *p = ram_e2cc;
  p[0] = 0x2b; p[1] = 0x30; p[2] = 0x7f; p[3] = 0x24; p[4] = 0; p[5] = 0; p[6] = 2;
  ram_e197++;
  p[7] = ram_e197;
  p[8] = a; p[9] = c;
  sendCOMM(3, 10);
  return ram_e2cc[7];
}
