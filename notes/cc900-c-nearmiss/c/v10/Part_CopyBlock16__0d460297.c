/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_1a.c (2026-11-16-30-p6-r1)
   sha256 0d4602979081b19630e392a553f4b00a47f318a801919b0bcf1285f383535a70 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near SEQ_SONG_RECORD[];
extern unsigned char SEQ_SONG_SLOTS[];
void Part_CopyBlock16(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else { a--; p = SEQ_SONG_SLOTS + (((unsigned long)a << 11) + 256); }
  q = buf; e = buf + 16;
  do *p++ = *q++; while (q < e);
}
