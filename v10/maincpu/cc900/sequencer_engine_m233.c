/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_28a6;
extern unsigned char __near ram_2310;
extern unsigned int __near SEQ_TRACK_MASK;
extern void Audio_CheckSubsystemReady(void);
extern void AccWrap_PositionClear(void);
extern void SeqBuf_WriteNoteOffEntry(int);
extern void NoteMap_SendAllNotesOff(void);
extern void AudioInit_RefreshToneBank(void);
extern void VoiceAlloc_ProcessAll(void);
extern void BitMapOut_PrepareAndDisplay(void);
extern void SeqPlay_EmergencyStopAll(void);
extern unsigned char __near SEQ_PLAY_FLAGS;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near SEQ_ACTIVE_PARTS;
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near ram_22fc;
extern unsigned char __near ram_28ae;
extern void AccWrap_PlayModeStopExpr(void);
extern void AccWrap_PlayModeDispatch(void);
extern void AccompSeq_StopSequence(void);
extern void MidiChannel_ResetAndConfigure(void);
extern void UI_PostTimerResetEvent(void);
extern void Demo_SelectEntry_AfterSongLoad(void);
extern void SeqPlay_StopAndResetAll(void);
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near ram_230a;
extern unsigned char __near ram_1d94;
extern unsigned int __near ram_2314;
extern unsigned char __near ram_431;
extern unsigned char __near ram_347a;
extern unsigned char __near ACC_LANES_ENDING1;
extern unsigned char __near ACC_LANES_ENDING2;
extern unsigned char __near ACC_LANES_ENDED;
extern void SeqAcc_ProcessTempoEvents(void);
extern void BitMapOut_PrepareAndDisplaySimple(void);
extern void SeqSyncPosMidiTiming(void);
extern void AccWrap_FullStop(void);
extern unsigned char SeqPlay_HandlePlaybackEvent(void);

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

void SeqPlay_StopAndResetAll(void)
{
  unsigned char a, f;
  if (SEQ_PLAY_FLAGS & 0x01) {
    if (SEQ_REC_TRACKS == 0) ram_22fc = 0;
    return;
  }
  a = ACC_TRANSPORT_STATE;
  if (!(a & 0x08) && (a & 0x04)) {
    if (!(SEQ_TRANSPORT_STATE & 0x04)) return;
    AccWrap_PlayModeStopExpr();
    ram_22fc = 0;
  } else AccWrap_PlayModeDispatch();
  SEQ_CONTROL_FLAGS &= ~0x20;
  SeqBuf_WriteNoteOffEntry(0x32);
  NoteMap_SendAllNotesOff();
  AudioInit_RefreshToneBank();
  VoiceAlloc_ProcessAll();
  AccompSeq_StopSequence();
  ram_28ae &= ~0x80;
  MidiChannel_ResetAndConfigure();
  SEQ_RTMCFG &= ~0x08;
  SEQ_START_MEASURE = 1;
  SEQ_ACTIVE_PARTS = 0;
  f = SEQ_CONTROL_FLAGS;
  f |= 0x10;
  f |= 0x04;
  SEQ_CONTROL_FLAGS = f;
  ram_22fc = 0;
  if (CURRENT_MODE == 19) {
    SEQ_TRACK_MASK = 0;
    Audio_CheckSubsystemReady();
    SEQ_ACTIVE_PARTS = 0;
    UI_PostTimerResetEvent();
    Demo_SelectEntry_AfterSongLoad();
  }
}

/* cc900-name: SeqSyncPosMidiTiming=Seq_SyncPositionAndOutputMIDITiming */
unsigned char SeqPlay_HandlePlaybackEvent(void)
{
  unsigned char e, c, a;
  unsigned int w;
  if (CURRENT_TITLE == 0x87 || CURRENT_TITLE == 0x88) { SeqAcc_ProcessTempoEvents(); return 0; }
  a = ram_230a;
  if (a & 0x02) { ram_230a = a & ~0x02; return 0; }
  ram_28ae &= ~0x80;
  ram_1d94 = 0;
  w = SEQ_ACTIVE_PARTS;
  ram_2314 = w;
  SEQ_ACTIVE_PARTS = 0;
  SeqBuf_WriteNoteOffEntry(0x32);
  NoteMap_SendAllNotesOff();
  AudioInit_RefreshToneBank();
  VoiceAlloc_ProcessAll();
  BitMapOut_PrepareAndDisplaySimple();
  AccompSeq_StopSequence();
  if (SEQ_TRACK_MASK != 0) {
    if (CURRENT_MODE == 19) {
      SEQ_TRACK_MASK = 0;
      Audio_CheckSubsystemReady();
      SEQ_ACTIVE_PARTS = 0;
    }
    SEQ_RTMCFG |= 0x04;
    SeqSyncPosMidiTiming();
    ram_431 = 0;
    Audio_CheckSubsystemReady();
    if (ram_347a & 0x04) {
      e = ACC_LANES_ENDING1;
      c = ACC_LANES_ENDING2;
      a = ACC_LANES_ENDED;
      if (e != 0 || c != 0 || a != 0) ram_28a6 &= ~0x01;
      else {
        ram_28a6 |= 0x01;
        ram_347a |= 0x02;
      }
    }
    if (ram_28a6 & 0x01) { AccWrap_FullStop(); SEQ_RTMCFG |= 0x02; }
    SEQ_RTMCFG &= ~0x04;
  }
  return 0;
}
