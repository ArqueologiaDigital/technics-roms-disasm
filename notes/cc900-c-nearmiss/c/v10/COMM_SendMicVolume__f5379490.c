/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5b.c (2026-11-16-45-p6-r9)
   sha256 f537949078528ed18dfc0b0b9e694946b4d167de54df22a7a21a6f0ca0494772 (tar-sha256); compiled at -O3 -Xr */
extern void SendCOMM_VariableLengthPacket(unsigned char *, int, int);
void COMM_SendMicVolume(unsigned char a)
{
  unsigned char *p = (unsigned char *)0xe354;
  if (*p == a) return;
  *p = a;
  SendCOMM_VariableLengthPacket(p, 7, 1);
}
