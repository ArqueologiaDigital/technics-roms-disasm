/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/note_voice_mapping.c (2026-11-16-55-p6-r10)
   sha256 ae6ea6f7a0e36a5f953acf483ff3903bae4bc1f974cfac28ea5280a3680b6353 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_e298;
void SendPartDataBlock_ClearByte2(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e298 != c) { ram_e298 = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe298, 0x22, 1); }
}
