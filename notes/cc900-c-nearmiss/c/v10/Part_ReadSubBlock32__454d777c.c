/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_2b.c (2026-11-16-35-p6-r3)
   sha256 454d777c57a47bdce681897b54082758f1f7c5ab8c73314b6fddcdcbecf34fe5 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned char SEQ_SONG_SLOTS[][0x800];
unsigned char Part_ReadSubBlock32(unsigned char a, unsigned char i)
{
  unsigned char *p;
  if (a == 0) p = SEQ_TRACK_ASSIGN;
  else p = SEQ_SONG_SLOTS[(unsigned char)(a - 1)] + 32;
  return (p + i)[-1];
}
