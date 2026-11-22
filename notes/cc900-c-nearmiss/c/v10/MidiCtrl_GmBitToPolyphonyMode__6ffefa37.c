/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m277b.c (2026-11-21-3-p6-r59)
   sha256 6ffefa378cfe19308fd19bd3bcd5e9fa5b79064166744d794cc133d0206f83bc (tar-sha256); compiled at -O3 -Xr */
extern void SubCPU_SetPolyphonyModeAndResendVolumes(unsigned int);
void MidiCtrl_GmBitToPolyphonyMode(unsigned char a)
{
  SubCPU_SetPolyphonyModeAndResendVolumes((a & 0x04) ? 1 : 0);
}
