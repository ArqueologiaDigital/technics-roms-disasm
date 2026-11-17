/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_14a.c (2026-11-16-100-p6-r19)
   sha256 85fbeeab11365f896e371bcac755fbdcf9888c9c7500cb9a0ebbc1e1bd869b02 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_OP_DEST_TRACK;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near ram_27d8;
extern unsigned int __near ram_27da;
extern void Part_ValidateVoiceChannel(unsigned int);
extern void SeqError_MapViaTableA(void);
extern void SeqVoice_InitReturnZero(void);
int SeqPart_SetupRightPos(void)
{
  Part_ValidateVoiceChannel(SEQ_OP_DEST_TRACK);
  if (SEQ_ERROR_CODE != 0) {
    SeqError_MapViaTableA();
    SeqVoice_InitReturnZero();
    return -1;
  }
  ram_27d8 = SEQ_DATA_BLOCK;
  ram_27da = 5;
  return 0;
}
