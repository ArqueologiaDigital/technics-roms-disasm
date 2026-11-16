/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_B_14a.c (2026-11-16-100-p6-r19)
   sha256 85fbeeab11365f896e371bcac755fbdcf9888c9c7500cb9a0ebbc1e1bd869b02 (tar-sha256); compiled at -O3 -XS -Xr */
/* Phase 6, helper B, round 14, form a: routines of v10's sequencer/sequencer_engine.s (-O3 -Xr) with
   memory-to-memory moves.  V4.23 writes ld (#16),(mem) / ld (mem),(#16) when one side is a __near cell, so the
   moved cells are __near (the firmware reaches them with 16-bit operands). */
/* cc900-module: SeqModeTransit_DemoPath SeqModeTransit_UpdateParts SeqPart_InitClear SeqPart_UndoAllocOnError */

extern unsigned char __near SEQ_PART_LOOP;
extern unsigned char __near ram_2546[];
extern unsigned char __near ram_2576[];
extern unsigned char __near ram_2587;
extern unsigned int __near ram_2526[];
extern unsigned int __near ram_2556[];
extern unsigned int __near ram_258e;
extern unsigned int __near ram_2590;
extern unsigned char __near ram_2592;
extern unsigned char __near ram_28a6;

/* the scan result (position 0x258e, byte 0x2587) into the slot tables of SEQ_PART_LOOP */
void VoiceChan_PostStatusEvent(void)
{
  ram_2546[SEQ_PART_LOOP] = ram_2587;
  ram_2526[SEQ_PART_LOOP] = ram_258e;
}

void SeqScan_StoreResultB(void)
{
  ram_2576[SEQ_PART_LOOP] = ram_2587;
  ram_2556[SEQ_PART_LOOP] = ram_258e;
}

/* keeps the latest (position, byte) pair seen: 0x2590 / 0x2592 */
void SeqScan_UpdateBestPositionA(void)
{
  unsigned int b = ram_258e, w = ram_2590;
  if (w > b) return;
  if (w == b && ram_2592 > ram_2587) return;
  ram_2590 = b;
  ram_2592 = ram_2587;
  ram_28a6 |= 0x01;
}

void SeqScan_UpdateBestPositionB(void)
{
  unsigned int b = ram_258e, w = ram_2590;
  if (w > b) return;
  if (w == b && ram_2592 > ram_2587) return;
  ram_2590 = b;
  ram_2592 = ram_2587;
  ram_28a6 &= ~0x01;
}

extern unsigned char __near ram_28a1;
extern unsigned char __near ram_289e;
extern unsigned int __near ram_28a2;
extern unsigned int __near SEQ_BLOCK_TOTAL;
extern unsigned long __near SEQ_BLOCK_POOL;
extern unsigned long __near ram_ce8;
extern unsigned int __near ram_d30;

void SeqVoice_SetDefaultParams(void)
{
  ram_28a1 = 16;
  ram_289e = 15;
  ram_28a2 = SEQ_BLOCK_TOTAL;
  ram_ce8 = SEQ_BLOCK_POOL;
  ram_d30 = 0;
}

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near GLOBAL_ERROR_CODE;

/* maps the sequencer error code through the table in XWA */
void SeqError_MapToGlobal(unsigned char *t)
{
  GLOBAL_ERROR_CODE = t[SEQ_ERROR_CODE];
}

extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned int __near ram_29ca;
extern unsigned int __near ram_29cc;

void SeqLoad_RestoreFreeBlockList(void)
{
  SEQ_FREE_LIST_HEAD = ram_29ca;
  SEQ_FREE_BLOCKS = ram_29cc;
}

extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_OP_DEST_TRACK;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near ram_27d4;
extern unsigned int __near ram_27d6;
extern unsigned int __near ram_27d8;
extern unsigned int __near ram_27da;
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

extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned char __near SEQ_SONG;
extern unsigned int __near ram_f1ce;
extern void Audio_CheckSubsystemReady(void);
extern void SeqData_CopyBlockToBuffer(unsigned int);
extern void VoicePreset_LoadAndInitPan(unsigned int);
extern void SeqVoice_InitEntryForCurrentBank(void);
extern void SeqStep_FindAndCompact(void);
extern void SeqVoice_InitEntry(void);

/* loads song slot a into the current record, keeping the record's word +78 */
void SingleLoad_PrepareSongSlot(unsigned char a)
{
  unsigned int k;
  SEQ_TRACK_MASK = SEQ_TRACK_MASK_COPY;
  Audio_CheckSubsystemReady();
  SeqData_CopyBlockToBuffer(SEQ_CURRENT_SONG);
  VoicePreset_LoadAndInitPan(a);
  SEQ_CURRENT_SONG = a;
  SeqVoice_InitEntryForCurrentBank();
  SeqData_CopyBlockToBuffer(SEQ_CURRENT_SONG);
  k = ram_f1ce;
  SeqStep_FindAndCompact();
  ram_f1ce = k;
}

void SeqVoice_InitEntryForCurrentBank(void)
{
  unsigned char s = SEQ_SONG;
  SEQ_SONG = SEQ_CURRENT_SONG;
  SeqVoice_InitEntry();
  SEQ_SONG = s;
}

extern unsigned char __near SEQ_CHORD_FROM_SONG;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near PLAY_TRANSPORT_STATE;
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near ram_28ac;
extern unsigned int __near ram_2838;
extern void SeqModeTransit_DemoPath(void);
extern void SeqModeTransit_UpdateParts(void);

void Seq_HandleModeTransition(void)
{
  unsigned char a;
  if (SEQ_TRACK_MASK == 0) { SEQ_CHORD_FROM_SONG = 0; SEQ_RTMCFG &= ~0x08; }
  PLAY_TRANSPORT_STATE &= ~0x10;
  PLAY_TRANSPORT_STATE &= ~0x02;
  a = ACC_TRANSPORT_STATE;
  a &= ~0x10;
  a &= ~0x02;
  ACC_TRANSPORT_STATE = a;
  if (CURRENT_MODE == 19) SeqModeTransit_DemoPath();
  else if ((ram_28ac & 0x20) || (!(SEQ_TRANSPORT_STATE & 0x04) && !(a & 0x04))) SeqModeTransit_UpdateParts();
  ram_2838 = SEQ_TRACK_MASK;
}

extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned char __near ram_2652;
extern unsigned char __near ram_282a;
extern unsigned int __near ram_27e8;
extern unsigned int __near ram_27ea;
extern unsigned int __near ram_27ec;
extern unsigned int __near ram_27ee;
extern void SeqPart_InitClear(void);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);

void SeqPart_UndoAllocOnError(void)
{
  if ((SEQ_EDIT_FLAGS & 0x80) && SEQ_ERROR_CODE != 0) {
    SEQ_TRACK = ram_2652;
    SeqPart_InitClear();
  }
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
