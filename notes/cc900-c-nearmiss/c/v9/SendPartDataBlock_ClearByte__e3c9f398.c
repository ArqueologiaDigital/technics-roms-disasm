/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/note_voice_mapping_m305.c (2026-11-16-68-p6-r12)
   sha256 e3c9f3987dac17786639adbc1ee301d632666d57bc418846a63b8780b817f58d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void SendCOMM_VariableLengthPacket(unsigned char *, int, int);
extern unsigned char __near ram_e357;
void SendPartDataBlock_ClearByte(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e357 != c) { ram_e357 = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe357, 0x21, 1); }
}
