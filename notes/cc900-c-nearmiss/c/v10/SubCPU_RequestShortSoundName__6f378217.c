/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5a.c (2026-11-16-45-p6-r9)
   sha256 6f3782173ed786acb5b8f0b9571ad10fbd5c29c845f28fb8a50c793a4f9e1a23 (tar-sha256); compiled at -O3 -Xr */
extern void sendCOMM(int, int);
extern unsigned char __near ram_e197;
extern unsigned char __near ram_e2cc[];
unsigned char SubCPU_RequestShortSoundName(unsigned char a, unsigned char c)
{
  unsigned char *p = ram_e2cc;
  p[0] = 0x2b; p[1] = 0x30; p[2] = 0x7f; p[3] = 0x24; p[4] = 0; p[5] = 0; p[6] = 2;
  p[7] = ++ram_e197;
  p[8] = a; p[9] = c;
  sendCOMM(3, 10);
  return ram_e2cc[7];
}
