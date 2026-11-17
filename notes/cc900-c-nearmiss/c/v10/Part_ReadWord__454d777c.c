/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_2b.c (2026-11-16-35-p6-r3)
   sha256 454d777c57a47bdce681897b54082758f1f7c5ab8c73314b6fddcdcbecf34fe5 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near SEQ_SONG_RECORD[];
unsigned int Part_ReadWord(unsigned char a, unsigned int o)
{
  unsigned int *p;
  if (a == 0) p = (unsigned int *)(SEQ_SONG_RECORD + o);
  else p = (unsigned int *)((unsigned char *)0xab000 + (((unsigned long)(unsigned char)(a - 1) << 11) + o));
  return *p;
}
