/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_3a.c (2026-11-16-38-p6-r6)
   sha256 08077e5f71e6fd71c8809069ff7c2ec22415c371e919999a81e5dbe9e7f09f47 (tar-sha256); compiled at -Xr */
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
