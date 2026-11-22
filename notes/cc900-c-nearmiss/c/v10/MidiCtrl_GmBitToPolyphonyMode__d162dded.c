/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m277a.c (2026-11-21-3-p6-r59)
   sha256 d162dded00a06dd9039c2e1495cb3ab30619d093e5deab7831b3e12816f45920 (tar-sha256); compiled at -Xr */
extern void SubCPU_SetPolyphonyModeAndResendVolumes(unsigned int);
void MidiCtrl_GmBitToPolyphonyMode(unsigned char a)
{
  unsigned char c = 0;
  if (a & 0x04) c = 1;
  SubCPU_SetPolyphonyModeAndResendVolumes(c);
}
