/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_3b.c (2026-11-16-38-p6-r6)
   sha256 fc0ec014df313a4af627cbf7507f0e11cc3de64de9b914dbdf302199fac3bcf2 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near SEQ_SONG_RECORD[];
extern unsigned char SEQ_SONG_SLOTS[];
void Part_CopyBlock16(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else p = SEQ_SONG_SLOTS + ((unsigned long)(unsigned char)(a - 1) << 11) + 256;
  q = buf; e = buf + 16;
  do *p++ = *q++; while (q < e);
}
