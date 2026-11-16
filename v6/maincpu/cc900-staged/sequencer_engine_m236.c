/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqModeTransit_DemoPath SeqModeTransit_UpdateParts SeqPart_InitClear SeqPart_UndoAllocOnError */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_OP_DEST_TRACK;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned char __near ram_2810;
extern unsigned int __near ram_27ce;
extern unsigned int __near ram_27d0;
extern unsigned int __near ram_27d2;
extern unsigned int __near ram_27d4;
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void SeqPart_UndoAllocOnError(void);
extern void SeqPart_PositionEqual(void);
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near ram_27ba;
extern unsigned int __near ram_27bc;
extern void Part_ValidateVoiceChannel(unsigned int);
extern void SeqError_MapViaTableA(void);
extern void SeqVoice_InitReturnZero(void);
extern int SeqPart_SetupLeftPos(void);
extern unsigned int __near ram_27be;
extern unsigned int __near ram_27c0;
extern int SeqPart_SetupRightPos(void);
extern unsigned char __near ram_2638;
extern void SeqPart_InitClear(void);

void SeqPart_PositionEqual(void)
{
  unsigned int b = ram_27d0;
  if ((SEQ_TRACK == 0x7f || SEQ_TRACK == SEQ_OP_DEST_TRACK) && (ram_2810 & 0x01) && (SEQ_EDIT_FLAGS & 0x08)) {
    b--;
    if (b <= 4) {
      ram_27ce = PartCtrl_ReadWord_Off1(ram_27ce);
      if (ram_27ce == 0) { SEQ_ERROR_CODE = 11; SeqPart_UndoAllocOnError(); return; }
      b = 0xff;
    }
  }
  ram_27d4 = b;
  ram_27d2 = ram_27ce;
}

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

int SeqPart_SetupRightPos(void)
{
  Part_ValidateVoiceChannel(SEQ_OP_DEST_TRACK);
  if (SEQ_ERROR_CODE != 0) {
    SeqError_MapViaTableA();
    SeqVoice_InitReturnZero();
    return -1;
  }
  ram_27be = SEQ_DATA_BLOCK;
  ram_27c0 = 5;
  return 0;
}

void SeqPart_UndoAllocOnError(void)
{
  if ((SEQ_EDIT_FLAGS & 0x80) && SEQ_ERROR_CODE != 0) {
    SEQ_TRACK = ram_2638;
    SeqPart_InitClear();
  }
}
