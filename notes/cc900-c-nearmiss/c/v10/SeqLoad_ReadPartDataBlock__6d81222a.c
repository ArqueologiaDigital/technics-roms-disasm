/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_18c.c (2026-11-16-128-p6-r27)
   sha256 6d81222a6f622e82cb5417bddd6e151e5f40b646fe2fe8fd7831a84ce05eebf5 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near ram_29ce[];
#define TBL_29CE ((unsigned int *)ram_29ce)
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
    pos += (unsigned long)ram_29ce[i] << 8;
    sum += ram_29ce[i];
  }
  pos += 1;
  for (i = 1; i < ram_29ce[a]; i++) {
    if ((r = FileIO_SeekAndRead16BitValue(pos, sum + i - 1)) != 0) { SeqData_SetErrorCode(200); return r; }
    if ((r = FileIO_SeekAndRead16BitValue(pos + 2, sum + i + 1)) != 0) { SeqData_SetErrorCode(201); return r; }
    pos += 256;
  }
  if ((r = FileIO_SeekAndRead16BitValue(pos, sum + i - 1)) != 0) { SeqData_SetErrorCode(202); return r; }
  if ((r = FileIO_SeekAndRead16BitValue(pos + 2, 0xffff)) != 0) { SeqData_SetErrorCode(203); return r; }
  return r;
}
