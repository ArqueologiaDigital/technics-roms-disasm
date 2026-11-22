/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/midi_dispatch_handlers_m288.c (2026-11-21-5-p6-r60)
   sha256 e374641f04df441905fa34ec79fd6a697da9ae60ab4a5e4f2733800c05572d3d (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SubCPU_SetPolyphonyModeAndResendVolumes(unsigned int);
void MidiCtrl_GmBitToPolyphonyMode(unsigned char a)
{
  unsigned char c = 0;
  if (a & 0x04) c = 1;
  SubCPU_SetPolyphonyModeAndResendVolumes(c);
}
