/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m236.c (2026-11-16-68-p6-r12)
   sha256 10a1cbe7c0ae694c34e234c103998dd69024a1909d7eb7c7d788affb834ac770 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern void SeqVoice_InitReturnZero(void);
extern void SeqVoice_SetDefaultParams(void);
extern void Part_SetClearVoiceBit7(unsigned int, unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_StealAndReallocVoices(unsigned int);
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned char __near SEQ_TRACK;
extern int Seq_ValidatePartNumber(unsigned int);
void SeqPart_InitClear(void)
{
  unsigned int v;
  SeqVoice_SetDefaultParams();
  if (Seq_ValidatePartNumber(SEQ_TRACK) != 0) SEQ_ERROR_CODE = 3;
  else {
    Part_WriteWord_Indexed(0, SEQ_TRACK, 0xffff);
    Part_WriteByte_Indexed(0, SEQ_TRACK, 5);
    if (Part_ReadVoiceBit7(0, SEQ_TRACK) != 0) {
      Part_SetClearVoiceBit7(0, SEQ_TRACK, 0);
      v = Part_ReadVoiceWord(0, SEQ_TRACK);
      if (v != 0xffff) {
        Part_WriteVoiceWord(0, SEQ_TRACK, 0xffff);
        Part_StealAndReallocVoices(v);
      }
    }
  }
  SeqVoice_InitReturnZero();
  Part_SetClearVoiceBit7((unsigned char)(SEQ_CURRENT_SONG + 1), SEQ_TRACK, 0);
  Part_WriteVoiceWord((unsigned char)(SEQ_CURRENT_SONG + 1), SEQ_TRACK, 0xffff);
  Part_WriteWord_Indexed((unsigned char)(SEQ_CURRENT_SONG + 1), SEQ_TRACK, 0xffff);
  Part_WriteByte_Indexed((unsigned char)(SEQ_CURRENT_SONG + 1), SEQ_TRACK, 5);
}
