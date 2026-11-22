/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midi_dispatch_handlers_m288.c (2026-11-21-5-p6-r60)
   sha256 9d619809f051bec6f7b5cd1ffaa98a8237126d65797326279fafcfa891e57a2f (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SubCPU_SetPolyphonyModeAndResendVolumes(unsigned int);
void MidiCtrl_GmBitToPolyphonyMode(unsigned char a)
{
  unsigned char c = 0;
  if (a & 0x04) c = 1;
  SubCPU_SetPolyphonyModeAndResendVolumes(c);
}
