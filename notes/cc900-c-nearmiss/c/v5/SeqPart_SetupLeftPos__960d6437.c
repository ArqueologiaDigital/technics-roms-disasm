/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m236.c (2026-11-16-111-p6-r22-staged)
   sha256 960d6437529a17d34c6b3d67bbabed763976045904e169102aa5e74cd6437bba (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_TRACK;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near ram_27ba;
extern unsigned int __near ram_27bc;
extern void Part_ValidateVoiceChannel(unsigned int);
extern void SeqError_MapViaTableA(void);
extern void SeqVoice_InitReturnZero(void);
int SeqPart_SetupLeftPos(void)
{
  Part_ValidateVoiceChannel(SEQ_TRACK);
  if (SEQ_ERROR_CODE != 0) {
    SeqError_MapViaTableA();
    SeqVoice_InitReturnZero();
    return -1;
  }
  ram_27ba = SEQ_DATA_BLOCK;
  ram_27bc = 5;
  return 0;
}
