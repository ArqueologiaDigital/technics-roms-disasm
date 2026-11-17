/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m236.c (2026-11-16-111-p6-r22-staged)
   sha256 e9b7e34b45d02464e7ed04d2c4c026c93e784e9704c878826315d10f39b5777a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned char __near ram_2652;
extern void SeqPart_InitClear(void);
void SeqPart_UndoAllocOnError(void)
{
  if ((SEQ_EDIT_FLAGS & 0x80) && SEQ_ERROR_CODE != 0) {
    SEQ_TRACK = ram_2652;
    SeqPart_InitClear();
  }
}
