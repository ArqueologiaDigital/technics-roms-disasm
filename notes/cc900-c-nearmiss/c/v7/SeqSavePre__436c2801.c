/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 436c280195261ab58a6879fafc91b12d3049967758304e75fcdb6dd2be32f122 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void Part_WriteByte(unsigned char, unsigned int, unsigned char);
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned char *SeqStep_ReinitPartTable(void);
extern void SeqData_CopyBlockToBuffer(unsigned int);
unsigned char *SeqSavePre(void)
{
  unsigned char *r = SeqStep_ReinitPartTable();
  SeqData_CopyBlockToBuffer(SEQ_CURRENT_SONG);
  Part_WriteByte(1, 4, 1);
  return r;
}
