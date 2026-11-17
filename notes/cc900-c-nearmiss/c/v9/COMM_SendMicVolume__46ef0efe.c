/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/note_voice_mapping.c (2026-11-16-55-p6-r10)
   sha256 46ef0efe4605efd77869d316d28ff905ba2b2cec5da8b130f11b506d691fd665 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_e354;
void COMM_SendMicVolume(unsigned char a)
{
  if (ram_e354 != a) { ram_e354 = a; SendCOMM_VariableLengthPacket((unsigned char *)0xe354, 7, 1); }
}
