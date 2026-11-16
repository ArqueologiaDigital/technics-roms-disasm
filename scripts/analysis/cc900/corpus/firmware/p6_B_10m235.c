/* Phase 6, helper B, round 10, module 235 of v10's sequencer/sequencer_engine.s (-O3 -Xr):
   FileIO_SeekAndRead16BitValue and SeqLoad_ReadPartDataBlock, which calls it with calr. */
/* cc900-module: FileIO_SeekAndRead16BitValue */

extern int FileIO_SeekAndReadBlock(unsigned long, unsigned int);
extern int FileIO_ReadByte_BufferHit(unsigned int);
extern void SeqData_SetErrorCode(unsigned char);
extern unsigned int __near ram_29ce[];

/* Seeks to pos and checks the 16-bit value v there, low byte first; 0 when both bytes match. */
long FileIO_SeekAndRead16BitValue(unsigned long pos, unsigned int v)
{
  long r = FileIO_SeekAndReadBlock(pos, 0);
  if (r != 0) return r;
  r = FileIO_ReadByte_BufferHit((unsigned char)v);
  if (r != 0) return r;
  r = FileIO_ReadByte_BufferHit((unsigned char)(v >> 8));
  return r;
}

/* Checks the block chain of part a in a song file being loaded: the block counts of parts 0..a-1 (0x29ce) give the
   file offset; each block's link words must be the running block numbers, the last one 0xffff.  Errors 200..203. */
long SeqLoad_ReadPartDataBlock(unsigned char a)
{
  unsigned long pos;
  unsigned int sum, i, b;
  long r;
  if (ram_29ce[a] == 0) return 0;
  pos = 0x800;
  sum = 0;
  for (i = 0; i < a; i++) {
    pos += (unsigned long)ram_29ce[i] << 8;
    sum += ram_29ce[i];
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
