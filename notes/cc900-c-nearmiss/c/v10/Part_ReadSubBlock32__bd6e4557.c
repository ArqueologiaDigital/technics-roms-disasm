/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_1b.c (2026-11-16-30-p6-r1)
   sha256 bd6e4557c8e04a2edcf7c0a4f18652e01cf59f735fd3362c0cbe758f01080833 (tar-sha256); compiled at -Xr */
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned char SEQ_SONG_SLOTS[][0x800];
unsigned char Part_ReadSubBlock32(unsigned char a, unsigned int i)
{
  unsigned char *p;
  if (a == 0) p = SEQ_TRACK_ASSIGN;
  else p = &SEQ_SONG_SLOTS[(unsigned char)(a - 1)][32];
  return *(p + i - 1);
}
