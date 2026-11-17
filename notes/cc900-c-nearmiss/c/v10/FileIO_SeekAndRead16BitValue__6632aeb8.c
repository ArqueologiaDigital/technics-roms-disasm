/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_10m235.c (2026-11-16-88-p6-r16)
   sha256 6632aeb8750d4bb8ecca279924dcff1171ecafb5affcabea8822572cb6e5d088 (tar-sha256); compiled at -O3 -Xr */
extern int FileIO_SeekAndReadBlock(unsigned long, unsigned int);
extern int FileIO_ReadByte_BufferHit(unsigned int);
long FileIO_SeekAndRead16BitValue(unsigned long pos, unsigned int v)
{
  long r = FileIO_SeekAndReadBlock(pos, 0);
  if (r != 0) return r;
  r = FileIO_ReadByte_BufferHit((unsigned char)v);
  if (r != 0) return r;
  r = FileIO_ReadByte_BufferHit((unsigned char)(v >> 8));
  return r;
}
