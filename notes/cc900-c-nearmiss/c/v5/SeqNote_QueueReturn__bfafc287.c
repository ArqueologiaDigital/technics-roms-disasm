/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 bfafc2875fa1d1fd79576b9677c9d023a72104b07c71ec3b3f8fc124f5de14a1 (tar-sha256); compiled at -O3 -Xr
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
