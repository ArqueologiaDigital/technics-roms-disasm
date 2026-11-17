/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_2a.c (2026-11-16-35-p6-r3)
   sha256 c97b2399af5c6580229970cea088ec622459e83731fa38d6c7f60b660d01c853 (tar-sha256); compiled at -O3 -Xr */
struct song { unsigned char h[32]; unsigned char tbl[224]; unsigned char blk[480]; unsigned char part[0x800 - 736]; };
extern unsigned char __near SEQ_SONG_RECORD[];
extern struct song SEQ_SONG_SLOTS[];
void Part_CopyBlock16(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else p = SEQ_SONG_SLOTS[(unsigned char)(a - 1)].blk;
  q = buf; e = buf + 16;
  do *p++ = *q++; while (q < e);
}
