/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_4b.c (2026-11-16-40-p6-r8)
   sha256 0376a2964c573ce15297eb22e016ddee3a48777d9bcdc1cb9292bc07c50265c4 (tar-sha256); compiled at -O3 -XS -Xr */
extern void SendCOMM_VariableLengthPacket(unsigned char *, int, int);
extern unsigned char __near ram_e354;
void COMM_SendMicVolume(unsigned char a)
{
  if (ram_e354 == a) return;
  ram_e354 = a;
  SendCOMM_VariableLengthPacket(&ram_e354, 7, 1);
}
