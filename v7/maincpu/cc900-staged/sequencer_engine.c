/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_28a6;
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern unsigned char __near ram_2310;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned int __near ram_2875;
extern unsigned char __near ram_28a5;
extern unsigned char __near ram_8c9c;

void SeqAcc_RestorePlaybackState(void)
{
  unsigned int m = ram_2875;
  SEQ_TRACK_MASK = m;
  Audio_CheckSubsystemReady();
  if (m != 0) {
    SEQ_RTMCFG &= ~0x08;
    SeqAcc_InitPlaybackState();
    Audio_CheckSubsystemReady();
    ram_28a5 |= 0x01;
  } else ram_28a5 &= ~0x01;
  CtrlPanel_SetIndicatorBit(0x4c);
}


void SeqLoad_RestorePartConfig(void)
{
  SEQ_CURRENT_SONG = Part_ReadByteDirect(1, 0xc7);
  Part_WriteByte(1, 0xc7, 0);
  SEQ_TRACK_MASK_COPY = Part_ReadWord(1, 0xc8);
  Part_WriteWord(1, 0xc8, 0);
  SEQ_START_MEASURE = 1;
  SEQ_RTMCFG &= ~0x08;
}

void SeqMode_SendStatusUpdate(void)
{
  switch (ram_8c9c) {
  case 0x81: ApDeliveryEvent(0x810005L, 0x1c0000fL, 1L); break;
  case 0x85: ApDeliveryEvent(0x850007L, 0x1c0000fL, 1L); break;
  case 0x87: ApDeliveryEvent(0x870003L, 0x1c0000fL, 1L); break;
  }
}

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

void SeqPlay_EmergencyStopAll(void)
{
  if (ram_2310 != 0) return;
  ram_2310 = 1;
  SEQ_TRACK_MASK = 0;
  Audio_CheckSubsystemReady();
  AccWrap_PositionClear();
  ram_28a6 &= ~0x01;
  SeqBuf_WriteNoteOffEntry(0x32);
  NoteMap_SendAllNotesOff();
  AudioInit_RefreshToneBank();
  VoiceAlloc_ProcessAll();
  BitMapOut_PrepareAndDisplay();
  ram_2310 = 0;
}


extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;

void SeqNote_QueueReturn(void)
{
  SEQ_DATA_OFFSET += 6;
  if (SEQ_DATA_OFFSET <= 0xff) return;
  SEQ_DATA_OFFSET -= 0x100;
  SEQ_DATA_OFFSET += 5;
  SEQ_DATA_BLOCK = PartCtrl_ReadWord(SEQ_DATA_BLOCK);
}
