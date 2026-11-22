/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/midi_dispatch_handlers_m288.c (2026-11-21-5-p6-r60)
   sha256 86e8e1e7575249b277ac7f677aa957a2256cbe115b140b26b0c9d7fb99f21e87 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SubCPU_SetPolyphonyModeAndResendVolumes(unsigned int);
void MidiCtrl_GmBitToPolyphonyMode(unsigned char a)
{
  unsigned char c = 0;
  if (a & 0x04) c = 1;
  SubCPU_SetPolyphonyModeAndResendVolumes(c);
}
