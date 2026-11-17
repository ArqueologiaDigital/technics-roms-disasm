/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m236.c (2026-11-16-111-p6-r22-staged)
   sha256 960d6437529a17d34c6b3d67bbabed763976045904e169102aa5e74cd6437bba (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned char __near ram_2638;
extern void SeqPart_InitClear(void);
void SeqPart_UndoAllocOnError(void)
{
  if ((SEQ_EDIT_FLAGS & 0x80) && SEQ_ERROR_CODE != 0) {
    SEQ_TRACK = ram_2638;
    SeqPart_InitClear();
  }
}
