/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_b.c (2026-11-16-40-p6-r8)
   sha256 bb91fc5534e321d3df1a30e2194c2b64805584e85701d3003e04357c7311bc4b (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_SONG_RECORD[];
extern unsigned char SEQ_SONG_SLOTS[];
void Part_CopyBlock16(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else p = SEQ_SONG_SLOTS + (unsigned long)((unsigned char *)((unsigned long)(unsigned char)(a - 1) << 11) + 256);
  q = buf; e = buf + 16;
  do *p++ = *q++; while (q < e);
}
