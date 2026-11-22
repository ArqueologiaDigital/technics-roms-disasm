/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Part_ValidateVoiceChannel / Part_ValidateAndSetupVoiceChannel, old-style definitions, taken by hand from
   notes/cc900-c-nearmiss/c/v10/Part_ValidateVoiceChannel__3ddde394.c (probe p6_S_31r1m234a.c, run 2026-11-22-15-p6-r82;
   stage_probe.py cannot read old-style heads).
   cc900-options: -O3 -Xr
*/
/* cc900-module: PartCtrl_TestBit7 Part_ReadVoiceBit7 Part_ReadVoiceWord Part_ValidateVoiceChannel SeqData_ReadNextByte */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near ram_f218[];
extern unsigned int __near ram_f1f8[];
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern unsigned char SeqData_ReadNextByte(void);
extern void Part_ValidateVoiceChannel();
extern void Part_ValidateAndSetupVoiceChannel();

void Part_ValidateVoiceChannel(a)
unsigned char a;
{
  unsigned int b;

  if (Part_ReadVoiceBit7(0, a) == 0) {
    SEQ_ERROR_CODE = 1;
    return;
  }
  b = Part_ReadVoiceWord(0, a);
  if (b == 0xffff) {
    SEQ_ERROR_CODE = 2;
    return;
  }
  if (b > 0x4d8) {
    SEQ_ERROR_CODE = 10;
    return;
  }
  if (PartCtrl_TestBit7(b) == 0) {
    SEQ_ERROR_CODE = 11;
    return;
  }
  SEQ_DATA_BLOCK = b;
  SEQ_DATA_OFFSET = 5;
  SEQ_ERROR_CODE = 0;
}

void Part_ValidateAndSetupVoiceChannel(a)
unsigned char a;
{
  unsigned char e;
  unsigned char o;
  unsigned int b;

  Part_ValidateVoiceChannel(a);
  e = SEQ_ERROR_CODE;
  if (e != 0) {
    if (e == 1)
      SEQ_ERROR_CODE = 0;
    return;
  }
  SEQ_ERROR_CODE = 0;
  o = ram_f218[(unsigned char)(a - 1)];
  if (o < 5) goto bad;
  b = ram_f1f8[(unsigned char)(a - 1)];
  if (b > 0x4d8) {
    SEQ_ERROR_CODE = 10;
    return;
  }
  if (PartCtrl_TestBit7(b) == 0) {
bad:
    SEQ_ERROR_CODE = 11;
    return;
  }
  SEQ_DATA_BLOCK = b;
  SEQ_DATA_OFFSET = o;
  if (SeqData_ReadNextByte() == 0x84)
    SEQ_ERROR_CODE = 6;
}

/* SeqVoice_FindChannelSetup: twin of the built SeqLoad_ProcessAllVoiceData (cc900/sequencer_engine_m235.c): the
   current song's parts read as song 0, the free list walked from SEQ_FREE_LIST_HEAD, and a found flag that picks
   the final reset. */
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned long __near SEQ_BLOCK_POOL;
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void Part_WriteWordBlock_OffsetAF(unsigned int);
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern void Part_UnlinkVoiceFromChain(void);
extern void Part_DeallocVoices1And2(void);
extern void SeqVoice_FindChannelSetup(void);

/* SeqPlay_HandleVoiceReassign: four pending-work checks run from the play loop. */
extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned char __near ACC_RUN_FLAGS;
extern unsigned char __near ram_1d90;
extern unsigned char __near ram_11f4;
extern unsigned char __near ram_1d5e;
extern unsigned char __near ram_1da0;
extern void SeqRestart_CheckAndDispatch(void);
extern void BitMapOut_PrepareAndRender(int);
extern void SeqPlay_AllocBuffersAndInit(void);
extern void SeqPlay_CheckStartConditions(void);
extern void SeqPlay_HandleVoiceReassign(void);
