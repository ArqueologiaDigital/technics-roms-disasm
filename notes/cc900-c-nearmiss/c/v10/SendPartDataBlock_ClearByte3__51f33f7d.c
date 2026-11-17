/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_4a.c (2026-11-16-40-p6-r8)
   sha256 51f33f7d2a542dcabaa0b35f2dc5bf07089f5d28b53e49e44f8cfe457d787e3c (tar-sha256); compiled at -O3 -XS -Xr */
extern void SendCOMM_VariableLengthPacket(unsigned char *, int, int);
extern unsigned char __near ram_e359;
void SendPartDataBlock_ClearByte3(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e359 == c) return;
  ram_e359 = c;
  SendCOMM_VariableLengthPacket((unsigned char *)0xe359, 0x24, 1);
}
