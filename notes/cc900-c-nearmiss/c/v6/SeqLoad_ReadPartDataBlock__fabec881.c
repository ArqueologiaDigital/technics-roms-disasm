/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m0.c (2026-11-17-1-p6-r28-staged)
   sha256 fabec8814a16cfa92f9739f42797a6a535f7f22ebbbdb75bc8b94ca7cc1c389a (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near ram_29b2[];
#define TBL_29CE ((unsigned int *)ram_29b2)
extern long FileIO_SeekAndRead16BitValue(unsigned long, unsigned int);
extern void SeqData_SetErrorCode(unsigned char);
long SeqLoad_ReadPartDataBlock(unsigned char a)
{
  unsigned long pos;
  unsigned int i, sum;
  long r;
  if (TBL_29CE[a] == 0) return 0;
  pos = 0x800;
  sum = 0;
  for (i = 0; i < a; i++) {
    pos += (unsigned long)ram_29b2[i] << 8;
    sum += ram_29b2[i];
  }
  pos += 1;
  for (i = 1; i < TBL_29CE[a]; i++) {
    if ((r = FileIO_SeekAndRead16BitValue(pos, sum + i - 1)) != 0) { SeqData_SetErrorCode(200); return r; }
    if ((r = FileIO_SeekAndRead16BitValue(pos + 2, sum + i + 1)) != 0) { SeqData_SetErrorCode(201); return r; }
    pos += 256;
  }
  if ((r = FileIO_SeekAndRead16BitValue(pos, sum + i - 1)) != 0) { SeqData_SetErrorCode(202); return r; }
  if ((r = FileIO_SeekAndRead16BitValue(pos + 2, 0xffff)) != 0) { SeqData_SetErrorCode(203); return r; }
  return r;
}
