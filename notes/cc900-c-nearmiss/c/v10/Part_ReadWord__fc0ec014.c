/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_3b.c (2026-11-16-38-p6-r6)
   sha256 fc0ec014df313a4af627cbf7507f0e11cc3de64de9b914dbdf302199fac3bcf2 (tar-sha256); compiled at -Xr */
struct song { unsigned char h[32]; unsigned char tbl[224]; unsigned char blk[480]; unsigned char part[0x800 - 736]; };
extern unsigned char __near SEQ_SONG_RECORD[];
extern struct song ram_ab000[];
unsigned int Part_ReadWord(unsigned char a, unsigned int o)
{
  unsigned char *p;
  if (a == 0) p = &SEQ_SONG_RECORD[o];
  else p = (unsigned char *)&ram_ab000[(unsigned char)(a - 1)] + o;
  return *(unsigned int *)p;
}
