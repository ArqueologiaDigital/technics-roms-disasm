/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_1b.c (2026-11-16-32-p6-m18-olevels)
   sha256 bd6e4557c8e04a2edcf7c0a4f18652e01cf59f735fd3362c0cbe758f01080833 (tar-sha256); compiled at -O2 -Xr */
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
unsigned char SeqVoice_FindDrumPartIndex(void)
{
  unsigned char i;
  SEQ_EDIT_FLAGS &= ~0x04;
  for (i = 0; i < 16; i++)
    if (SEQ_TRACK_ASSIGN[i] == 0x10) { SEQ_EDIT_FLAGS |= 0x04; return i + 1; }
  return 0;
}
