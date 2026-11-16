/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_3b.c (2026-11-16-38-p6-r6)
   sha256 fc0ec014df313a4af627cbf7507f0e11cc3de64de9b914dbdf302199fac3bcf2 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned char SEQ_SONG_SLOTS[];
unsigned char Part_ReadSubBlock32(unsigned char a, unsigned char i)
{
  unsigned char *p;
  if (a == 0) p = SEQ_TRACK_ASSIGN;
  else p = SEQ_SONG_SLOTS + ((unsigned long)(unsigned char)(a - 1) << 11) + 32;
  return *(p + i - 1);
}
