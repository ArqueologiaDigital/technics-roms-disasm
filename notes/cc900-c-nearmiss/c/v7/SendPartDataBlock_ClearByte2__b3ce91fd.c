/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/note_voice_mapping_m305.c (2026-11-16-68-p6-r12)
   sha256 b3ce91fdac5ca7071d65a93b2e8d2fa44c0d4127c4ed2bdb10f6b4aa48ac2bd8 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void SendCOMM_VariableLengthPacket(unsigned char *, int, int);
extern unsigned char __near ram_e2bc;
void SendPartDataBlock_ClearByte2(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e2bc != c) { ram_e2bc = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe2bc, 0x22, 1); }
}
