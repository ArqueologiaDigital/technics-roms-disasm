/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_1a.c (2026-11-16-32-p6-m18-olevels)
   sha256 0d4602979081b19630e392a553f4b00a47f318a801919b0bcf1285f383535a70 (tar-sha256); compiled at -O2 -Xr */
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
unsigned char SeqVoice_FindDrumPartIndex(void)
{
  unsigned char i;
  SEQ_EDIT_FLAGS &= ~0x04;
  i = 0;
  do {
    if (SEQ_TRACK_ASSIGN[i] == 0x10) { SEQ_EDIT_FLAGS |= 0x04; return i + 1; }
    i++;
  } while (i < 16);
  return 0;
}
