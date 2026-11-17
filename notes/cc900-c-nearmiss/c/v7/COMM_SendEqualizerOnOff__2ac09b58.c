/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/note_voice_mapping.c (2026-11-16-55-p6-r10)
   sha256 2ac09b58c86184e8cf24523962a18d4592e78ca191a229cd1a3daa6760f9782a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_e2be;
void COMM_SendEqualizerOnOff(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e2be != c) { ram_e2be = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe2be, 37, 1); }
}
