/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_4b.c (2026-11-16-40-p6-r8)
   sha256 0376a2964c573ce15297eb22e016ddee3a48777d9bcdc1cb9292bc07c50265c4 (tar-sha256); compiled at -O3 -XS -Xr */
extern void sendCOMM(int, int);
extern unsigned char __near ram_e197;
extern unsigned char __near ram_e2cc[];
unsigned char SubCPU_RequestShortSoundName(unsigned char a, unsigned char c)
{
  ram_e2cc[0] = 0x2b; ram_e2cc[1] = 0x30; ram_e2cc[2] = 0x7f; ram_e2cc[3] = 0x24; ram_e2cc[4] = 0; ram_e2cc[5] = 0; ram_e2cc[6] = 2;
  ram_e197++;
  ram_e2cc[7] = ram_e197;
  ram_e2cc[8] = a; ram_e2cc[9] = c;
  sendCOMM(3, 10);
  return ram_e2cc[7];
}
