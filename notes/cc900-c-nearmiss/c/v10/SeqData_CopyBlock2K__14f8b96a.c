/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_b.c (2026-11-16-40-p6-r8)
   sha256 14f8b96aff0b38effad950d456b950c5504f5659cb8502f38394eb417d70dc68 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_SONG_RECORD[];
extern unsigned char SEQ_SONG_SLOTS[];
void SeqData_CopyBlock2K(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else p = SEQ_SONG_SLOTS + (unsigned long)((unsigned char *)((unsigned long)(unsigned char)(a - 1) << 11) + 256);
  q = buf; e = buf + 16;
  do *q++ = *p++; while (q < e);
}
