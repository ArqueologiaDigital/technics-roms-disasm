/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/note_voice_mapping_m305.c (2026-11-16-68-p6-r12)
   sha256 02665a0933975e3e003a0b2e3d3ea7c9ce0bb8bb22b2d0e736a7553ddbbb3373 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void SendCOMM_VariableLengthPacket(unsigned char *, int, int);
extern unsigned char __near ram_e293;
void COMM_SendFadeLevel(unsigned char a)
{
  if (ram_e293 != a) { ram_e293 = a; SendCOMM_VariableLengthPacket((unsigned char *)0xe293, 6, 1); }
}
