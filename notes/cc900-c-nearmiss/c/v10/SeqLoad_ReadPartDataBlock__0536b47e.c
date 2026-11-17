/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_17c.c (2026-11-16-123-p6-r25)
   sha256 0536b47edacf4da52d1688dc7ec8a7cec2c512b91313e971d3def973fb9e2212 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near ram_29ce[];
#define TBL_29CE ((unsigned int *)ram_29ce)
extern long FileIO_SeekAndRead16BitValue(unsigned long, unsigned int);
extern void SeqData_SetErrorCode(unsigned char);
long SeqLoad_ReadPartDataBlock(unsigned char a)
{
  unsigned long pos;
  unsigned int i, sum;
  unsigned int b;
  long r;
  if (TBL_29CE[a] == 0) return 0;
  pos = 0x800;
  sum = 0;
  for (i = 0; i < a; i++) {
    pos += (unsigned long)TBL_29CE[i] << 8;
    sum += TBL_29CE[i];
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
  if (i < TBL_29CE[a]) goto loop;
  if ((r = FileIO_SeekAndRead16BitValue(pos, b)) != 0) { SeqData_SetErrorCode(202); return r; }
  if ((r = FileIO_SeekAndRead16BitValue(pos + 2, 0xffff)) != 0) { SeqData_SetErrorCode(203); return r; }
  return r;
}
