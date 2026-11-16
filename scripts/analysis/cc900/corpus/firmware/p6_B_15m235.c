/* Phase 6, helper B, round 15, module 235 of v10's sequencer/sequencer_engine.s (-O3 -Xr):
   SeqLoad_ReadPartDataBlock, refined from round 12 (+7 in run r19: the firmware computes the index a * 2 before it
   loads the table address, and reads the entry through the register-held base). */
/* cc900-module: FileIO_SeekAndRead16BitValue */

extern long FileIO_SeekAndRead16BitValue(unsigned long, unsigned int);
extern void SeqData_SetErrorCode(unsigned char);
extern unsigned int __near ram_29ce[];

long SeqLoad_ReadPartDataBlock(unsigned char a)
{
  unsigned int sum, i;
  unsigned long pos;
  unsigned int *t;
  unsigned int k, b;
  long r;
  k = a * 2;
  t = ram_29ce;
  if (*(unsigned int *)((unsigned char *)t + k) == 0) return 0;
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
