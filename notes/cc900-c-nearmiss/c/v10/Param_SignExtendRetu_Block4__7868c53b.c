/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_7a.c (2026-11-16-53-p6-r11)
   sha256 7868c53b4be9ae7e465581991b52a8087d74fac06d150e81c007ed067f52a205 (tar-sha256); compiled at -O3 -XS -Xr */
extern void sendCOMM(int, int);
extern unsigned char __near ram_e197;
extern unsigned char __near ram_e2c2[];
unsigned char Param_SignExtendRetu_Block4(unsigned char a, unsigned char c)
{
  ram_e2c2[0] = 0x2b; ram_e2c2[1] = 0x30; ram_e2c2[2] = 0x7f; ram_e2c2[3] = 0x22; ram_e2c2[4] = 0; ram_e2c2[5] = 0; ram_e2c2[6] = 2;
  ram_e197++;
  ram_e2c2[7] = ram_e197 & 0x7f;
  ram_e2c2[8] = a; ram_e2c2[9] = c;
  sendCOMM(3, 10);
  return ram_e2c2[7];
}
