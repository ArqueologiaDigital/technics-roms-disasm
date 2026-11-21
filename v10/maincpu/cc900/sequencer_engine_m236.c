/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
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
extern unsigned char __near ram_2684;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern void SeqError_MapViaTableF(void);
extern unsigned char __near ram_2879;
extern unsigned char __near ram_289d;
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
  SEQ_TRACK_ASSIGN[(unsigned char)(ram_2684 - 1)] = a;
  Part_SetClearVoiceBit7(0, ram_2684, 1);
  Part_WriteVoiceWord(0, ram_2684, b);
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
  ram_2879 &= ~0x01;
  ram_2879 &= ~0x02;
  ram_289d &= ~0x01;
  ram_289d &= ~0x04;
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

/* cc900-module: SeqModeTransit_DemoPath SeqModeTransit_UpdateParts SeqPart_InitClear SeqPart_UndoAllocOnError */
extern unsigned int __near SEQOP_SECONDARY_BLOCK;
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern unsigned int __near ram_265c;
extern unsigned int __near ram_265e;
extern unsigned long __near ram_25da;
extern void PartCtrl_WriteByte_ZeroExtended(unsigned int, unsigned int, unsigned int);
extern void PartCtrl_ReadWordWithBoundsCheck(unsigned int *, unsigned int *);
extern void SeqPart_ReplayForward(void);
extern unsigned char __near SEQ_OP_DEST_TRACK;
extern unsigned char __near ram_282a;
extern unsigned int __near ram_27e8;
extern unsigned int __near ram_27ea;
extern unsigned int __near ram_27ec;
extern unsigned int __near ram_27ee;
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void SeqPart_UndoAllocOnError(void);
extern void SeqPart_PositionEqual(void);
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near ram_27d4;
extern unsigned int __near ram_27d6;
extern void Part_ValidateVoiceChannel(unsigned int);
extern int SeqPart_SetupLeftPos(void);
extern unsigned int __near ram_27d8;
extern unsigned int __near ram_27da;
extern int SeqPart_SetupRightPos(void);
extern unsigned char __near ram_2652;
extern void SeqPart_InitClear(void);

void SeqPart_ReplayForward(void)
{
  unsigned long i;
  SEQ_ERROR_CODE = 0;
  SEQOP_SECONDARY_BLOCK = ram_265c;
  SEQOP_SECONDARY_OFFSET = ram_265e;
  ram_25da = ram_25da - 1;
  i = 0;
  while (ram_25da != i) {
    PartCtrl_WriteByte_ZeroExtended(SEQOP_SECONDARY_BLOCK, SEQOP_SECONDARY_OFFSET, 0x81);
    i++;
    PartCtrl_ReadWordWithBoundsCheck(&SEQOP_SECONDARY_BLOCK, &SEQOP_SECONDARY_OFFSET);
    if (SEQ_ERROR_CODE != 0) return;
  }
  PartCtrl_WriteByte_ZeroExtended(SEQOP_SECONDARY_BLOCK, SEQOP_SECONDARY_OFFSET, 0x82);
}
void SeqPart_PositionEqual(void)
{
  unsigned int b = ram_27ea;
  if ((SEQ_TRACK == 0x7f || SEQ_TRACK == SEQ_OP_DEST_TRACK) && (ram_282a & 0x01) && (SEQ_EDIT_FLAGS & 0x08)) {
    b--;
    if (b <= 4) {
      ram_27e8 = PartCtrl_ReadWord_Off1(ram_27e8);
      if (ram_27e8 == 0) { SEQ_ERROR_CODE = 11; SeqPart_UndoAllocOnError(); return; }
      b = 0xff;
    }
  }
  ram_27ee = b;
  ram_27ec = ram_27e8;
}
int SeqPart_SetupLeftPos(void)
{
  Part_ValidateVoiceChannel(SEQ_TRACK);
  if (SEQ_ERROR_CODE != 0) {
    SeqError_MapViaTableA();
    SeqVoice_InitReturnZero();
    return -1;
  }
  ram_27d4 = SEQ_DATA_BLOCK;
  ram_27d6 = 5;
  return 0;
}
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
void SeqPart_UndoAllocOnError(void)
{
  if ((SEQ_EDIT_FLAGS & 0x80) && SEQ_ERROR_CODE != 0) {
    SEQ_TRACK = ram_2652;
    SeqPart_InitClear();
  }
}

/* cc900-module: SeqPart_CompareLeft SeqPart_CompareRight */
extern unsigned char __near ram_27d2;
extern unsigned int __near ram_287d;
extern void SeqPart_WriteByte_Primary(int);
extern void Part_WriteWordAndByte(unsigned int, unsigned int);
extern void PartCtrl_AdvanceToNextEntry(void);
extern unsigned char SeqPart_CompareLeft(void);
extern unsigned char SeqPart_CompareRight(void);
extern void SeqPart_DualSwap(unsigned char a, unsigned char *l, unsigned char *r);

void SeqPart_DualSwap(unsigned char a, unsigned char *l, unsigned char *r)
{
	if (a == 0x82) {
		SeqPart_WriteByte_Primary(a);
		ram_27d2 = 0xff;
		ram_287d = ram_2684;
		Part_WriteWordAndByte(SEQOP_PRIMARY_BLOCK, (unsigned char)SEQOP_PRIMARY_OFFSET);
	} else {
		SeqPart_WriteByte_Primary(0x81);
		PartCtrl_AdvanceToNextEntry();
		PartCtrl_ReadWordWithBoundsCheck(&ram_27d4, &ram_27d6);
		*l = SeqPart_CompareLeft();
		PartCtrl_ReadWordWithBoundsCheck(&ram_27d8, &ram_27da);
		*r = SeqPart_CompareRight();
	}
}

/* cc900-module: SeqPart_EventLoop */
extern unsigned char __near ram_ce5;
extern void SeqPart_EventLoop(unsigned int);
extern void SeqPart_SetupWithDispatch(void);

void SeqPart_SetupWithDispatch(void)
{
	SEQ_ERROR_CODE = 0;
	ram_2879 &= ~0x01;
	ram_2879 &= ~0x02;
	SeqVoice_SetDefaultParams();
	if (ram_ce5 > 15) {
		SeqVoice_InitReturnZero();
		return;
	}
	if (SEQ_TRACK_ASSIGN[(unsigned char)(SEQ_TRACK - 1)] == 12)
		ram_2879 |= 0x01;
	if (SEQ_TRACK_ASSIGN[(unsigned char)(SEQ_OP_DEST_TRACK - 1)] == 12)
		ram_2879 |= 0x02;
	SeqPart_EventLoop((unsigned char)(ram_ce5 + 1));
	SeqVoice_InitReturnZero();
	ram_2879 &= ~0x01;
	ram_2879 &= ~0x02;
}

/* cc900-module: SeqStep_ParseRhythm SeqStep_SkipToMeasure */
extern unsigned char __near ram_d32;
extern unsigned char __near TRACK_ASSIGN_EDIT_VALUE;
extern void SeqStep_ParseRhythm(void);
extern void SeqPart_EventLoopContinue(void);

void SeqPart_EventLoopContinue(void)
{
  ram_d32 = TRACK_ASSIGN_EDIT_VALUE;
  SeqStep_ParseRhythm();
}
