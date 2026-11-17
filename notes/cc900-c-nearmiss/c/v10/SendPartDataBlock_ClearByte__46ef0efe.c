/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/note_voice_mapping.c (2026-11-16-55-p6-r10)
   sha256 46ef0efe4605efd77869d316d28ff905ba2b2cec5da8b130f11b506d691fd665 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_e357;
void SendPartDataBlock_ClearByte(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e357 != c) { ram_e357 = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe357, 0x21, 1); }
}
