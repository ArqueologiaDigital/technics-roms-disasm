/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_12m235.c (2026-11-16-100-p6-r19)
   sha256 3e7e5ada9ac32b3de2b47b87dbe31a76135f3becf5975f9bc9bdba393eec3b4d (tar-sha256); compiled at -O3 -Xr */
extern int FileIO_SeekAndReadBlock(unsigned long, unsigned int);
extern int FileIO_ReadByte_BufferHit(unsigned int);
long FileIO_SeekAndRead16BitValue(unsigned long pos, unsigned int v)
{
  long r = FileIO_SeekAndReadBlock(pos, 0);
  if (r != 0) return r;
  r = FileIO_ReadByte_BufferHit(v & 0xff);
  if (r != 0) return r;
  r = FileIO_ReadByte_BufferHit(v >> 8);
  return r;
}
