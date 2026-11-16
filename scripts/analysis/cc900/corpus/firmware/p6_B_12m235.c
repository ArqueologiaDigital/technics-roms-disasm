/* Phase 6, helper B, round 12, module 235 of v10's sequencer/sequencer_engine.s (-O3 -Xr):
   FileIO_SeekAndRead16BitValue and SeqLoad_ReadPartDataBlock (refined from round 10: the low byte as v & 0xff;
   the stack scalars declared highest slot first; the block-count table through a local pointer). */
/* cc900-module: FileIO_SeekAndRead16BitValue */

extern int FileIO_SeekAndReadBlock(unsigned long, unsigned int);
extern int FileIO_ReadByte_BufferHit(unsigned int);
extern void SeqData_SetErrorCode(unsigned char);
extern unsigned int __near ram_29ce[];

long FileIO_SeekAndRead16BitValue(unsigned long pos, unsigned int v)
{
  long r = FileIO_SeekAndReadBlock(pos, 0);
  if (r != 0) return r;
  r = FileIO_ReadByte_BufferHit(v & 0xff);
  if (r != 0) return r;
  r = FileIO_ReadByte_BufferHit(v >> 8);
  return r;
}

long SeqLoad_ReadPartDataBlock(unsigned char a)
{
  unsigned int sum, i;
  unsigned long pos;
  unsigned int *t;
  unsigned int b;
  long r;
  t = ram_29ce;
  if (t[a] == 0) return 0;
  pos = 0x800;
  sum = 0;
  for (i = 0; i < a; i++) {
    pos += (unsigned long)t[i] << 8;
    sum += t[i];
  }
  pos += 1;
  i = 1;
  goto test;
loop:
  if ((r = FileIO_SeekAndRead16BitValue(pos, b)) != 0) { SeqData_SetErrorCode(200); return r; }
  if ((r = FileIO_SeekAndRead16BitValue(pos + 2, sum + i + 1)) != 0) { SeqData_SetErrorCode(201); return r; }
  pos += 256;
  i++;
test:
  b = sum + i - 1;
  if (i < ram_29ce[a]) goto loop;
  if ((r = FileIO_SeekAndRead16BitValue(pos, b)) != 0) { SeqData_SetErrorCode(202); return r; }
  if ((r = FileIO_SeekAndRead16BitValue(pos + 2, 0xffff)) != 0) { SeqData_SetErrorCode(203); return r; }
  return r;
}
