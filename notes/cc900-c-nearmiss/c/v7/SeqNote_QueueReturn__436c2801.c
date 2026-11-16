/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 436c280195261ab58a6879fafc91b12d3049967758304e75fcdb6dd2be32f122 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int PartCtrl_ReadWord(unsigned int);
void SeqNote_QueueReturn(void)
{
  SEQ_DATA_OFFSET += 6;
  if (SEQ_DATA_OFFSET <= 0xff) return;
  SEQ_DATA_OFFSET -= 0x100;
  SEQ_DATA_OFFSET += 5;
  SEQ_DATA_BLOCK = PartCtrl_ReadWord(SEQ_DATA_BLOCK);
}
