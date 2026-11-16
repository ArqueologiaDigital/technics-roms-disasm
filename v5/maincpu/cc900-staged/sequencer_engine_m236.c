/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern void SeqError_MapViaTableA(void);
extern void SeqVoice_InitReturnZero(void);
extern unsigned char __near SEQ_EDIT_FLAGS;
extern void SeqVoice_SetDefaultParams(void);
extern int SeqAccPlay_InitAndDispatch(void);
extern unsigned int Part_ProcessAndDecrementVoice(void);
extern void Part_SetClearVoiceBit7(unsigned int, unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern unsigned char __near ram_266a;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern void SeqError_MapViaTableF(void);
extern unsigned char __near ram_285d;
extern unsigned char __near ram_2881;
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_StealAndReallocVoices(unsigned int);
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned char __near SEQ_TRACK;
extern int Seq_ValidatePartNumber(unsigned int);

unsigned char SeqPart_CheckVoiceType(unsigned char a)
{
  unsigned char t;
  a--;
  t = SEQ_TRACK_ASSIGN[a];
  if (t != 15 && t != 16 && t != 13) return t;
  SEQ_ERROR_CODE = 9;
  SeqError_MapViaTableA();
  SeqVoice_InitReturnZero();
  return 0xff;
}

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

int SeqPart_AllocNewEntry(unsigned char a)
{
  unsigned int b = Part_ProcessAndDecrementVoice();
  if (b == 0xffff) return -1;
  SEQ_TRACK_ASSIGN[(unsigned char)(ram_266a - 1)] = a;
  Part_SetClearVoiceBit7(0, ram_266a, 1);
  Part_WriteVoiceWord(0, ram_266a, b);
  SEQOP_PRIMARY_BLOCK = b;
  SEQOP_PRIMARY_OFFSET = 5;
  PartCtrl_WriteWord_Off1(b, 0);
  PartCtrl_WriteWord(b, 0xffff);
  return 0;
}

void SeqPart_ByteBlockA95A_Code_Helper(void)
{
  SeqError_MapViaTableF();
  SeqVoice_InitReturnZero();
  ram_285d &= ~0x01;
  ram_285d &= ~0x02;
  ram_2881 &= ~0x01;
  ram_2881 &= ~0x04;
}

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
