/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_4b.c (2026-11-16-40-p6-r8)
   sha256 0376a2964c573ce15297eb22e016ddee3a48777d9bcdc1cb9292bc07c50265c4 (tar-sha256); compiled at -O3 -XS -Xr */
extern void SendCOMM_VariableLengthPacket(unsigned char *, int, int);
extern unsigned char __near ram_e359;
void SendPartDataBlock_ClearByte3(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e359 == c) return;
  ram_e359 = c;
  SendCOMM_VariableLengthPacket(&ram_e359, 0x24, 1);
}
