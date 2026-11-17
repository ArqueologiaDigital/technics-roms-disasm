/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/note_voice_mapping_m305.c (2026-11-16-68-p6-r12)
   sha256 e3c9f3987dac17786639adbc1ee301d632666d57bc418846a63b8780b817f58d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void SendCOMM_VariableLengthPacket(unsigned char *, int, int);
extern unsigned char __near ram_e354;
void COMM_SendMicVolume(unsigned char a)
{
  if (ram_e354 != a) { ram_e354 = a; SendCOMM_VariableLengthPacket((unsigned char *)0xe354, 7, 1); }
}
