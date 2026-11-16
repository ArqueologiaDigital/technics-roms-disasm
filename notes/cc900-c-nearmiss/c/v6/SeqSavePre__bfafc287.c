/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 bfafc2875fa1d1fd79576b9677c9d023a72104b07c71ec3b3f8fc124f5de14a1 (tar-sha256); compiled at -O3 -Xr
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
