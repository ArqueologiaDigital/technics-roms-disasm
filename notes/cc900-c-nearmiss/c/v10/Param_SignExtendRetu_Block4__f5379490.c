/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5b.c (2026-11-16-45-p6-r9)
   sha256 f537949078528ed18dfc0b0b9e694946b4d167de54df22a7a21a6f0ca0494772 (tar-sha256); compiled at -O3 -Xr */
extern void sendCOMM(int, int);
extern unsigned char __near ram_e197;
extern unsigned char __near ram_e2c2[];
unsigned char Param_SignExtendRetu_Block4(unsigned char a, unsigned char c)
{
  unsigned char *p = ram_e2c2;
  unsigned char s;
  p[0] = 0x2b; p[1] = 0x30; p[2] = 0x7f; p[3] = 0x22; p[4] = 0; p[5] = 0; p[6] = 2;
  ram_e197++;
  s = ram_e197;
  p[7] = s;
  p[8] = a; p[9] = c;
  sendCOMM(3, 10);
  return ram_e2c2[7];
}
