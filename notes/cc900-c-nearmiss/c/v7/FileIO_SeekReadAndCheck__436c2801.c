/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 436c280195261ab58a6879fafc91b12d3049967758304e75fcdb6dd2be32f122 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern int FileIO_SeekAndReadBlock(unsigned long, unsigned int);
extern int FileIO_ReadByte_BufferHit(unsigned int);
long FileIO_SeekReadAndCheck(unsigned long a, unsigned char c)
{
  long r = FileIO_SeekAndReadBlock(a, 0);
  if (r == 0) r = FileIO_ReadByte_BufferHit(c);
  return r;
}
