/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_1b.c (2026-11-16-30-p6-r1)
   sha256 bd6e4557c8e04a2edcf7c0a4f18652e01cf59f735fd3362c0cbe758f01080833 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near SEQ_SONG_RECORD[];
unsigned int Part_ReadWord(unsigned char a, unsigned int o)
{
  unsigned long p;
  if (a == 0) p = (unsigned long)&SEQ_SONG_RECORD[o];
  else p = 0xab000L + ((unsigned long)(unsigned char)(a - 1) << 11) + o;
  return *(unsigned int *)p;
}
