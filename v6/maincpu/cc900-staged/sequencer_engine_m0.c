/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FileIO_SeekAndRead16BitValue NotePool_InsertEntry SeqAcc_InitPlayback_FreshStart SeqPlay_CheckDrumPartAndClearCounters SeqPlay_ReactivatePartsAndResume SeqPlay_RestartWithVoiceConfig */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near ram_29b2[];
#define TBL_29CE ((unsigned int *)ram_29b2)
extern long FileIO_SeekAndRead16BitValue(unsigned long, unsigned int);
extern void SeqData_SetErrorCode(unsigned char);
extern long SeqLoad_ReadPartDataBlock(unsigned char a);

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
