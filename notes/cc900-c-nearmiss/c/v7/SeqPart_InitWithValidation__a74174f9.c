/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m236.c (2026-11-16-68-p6-r12)
   sha256 a74174f9a0f0750c872a059b7166073bef5353e1a12db7a63499df86e524d102 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern void SeqError_MapViaTableA(void);
extern void SeqVoice_InitReturnZero(void);
extern unsigned char __near SEQ_EDIT_FLAGS;
extern void SeqVoice_SetDefaultParams(void);
extern int SeqAccPlay_InitAndDispatch(void);
int SeqPart_InitWithValidation(void)
{
  SeqVoice_SetDefaultParams();
  if (SeqAccPlay_InitAndDispatch() != 0) {
    SEQ_ERROR_CODE = 3;
    SeqError_MapViaTableA();
    SeqVoice_InitReturnZero();
    return -1;
  }
  SEQ_ERROR_CODE = 0;
  SEQ_EDIT_FLAGS &= ~0x40;
  return 0;
}
