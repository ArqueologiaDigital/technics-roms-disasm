/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_4a.c (2026-11-16-40-p6-r8)
   sha256 51f33f7d2a542dcabaa0b35f2dc5bf07089f5d28b53e49e44f8cfe457d787e3c (tar-sha256); compiled at -O3 -Xr */
extern void SendCOMM_VariableLengthPacket(unsigned char *, int, int);
extern unsigned char __near ram_e354;
void COMM_SendMicVolume(unsigned char a)
{
  if (ram_e354 == a) return;
  ram_e354 = a;
  SendCOMM_VariableLengthPacket((unsigned char *)0xe354, 7, 1);
}
