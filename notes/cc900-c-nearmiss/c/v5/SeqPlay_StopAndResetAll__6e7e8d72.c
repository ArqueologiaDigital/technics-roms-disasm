/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m233.c (2026-11-16-68-p6-r12)
   sha256 6e7e8d72d390ba05a63151faa142c5bb60f1d880c264b1b874d7257f95b2f544 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_TRACK_MASK;
extern void Audio_CheckSubsystemReady(void);
extern void SeqBuf_WriteNoteOffEntry(int);
extern void NoteMap_SendAllNotesOff(void);
extern void AudioInit_RefreshToneBank(void);
extern void VoiceAlloc_ProcessAll(void);
extern unsigned char __near SEQ_PLAY_FLAGS;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near SEQ_ACTIVE_PARTS;
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near ram_22f6;
extern unsigned char __near ram_2892;
extern void AccWrap_PlayModeStopExpr(void);
extern void AccWrap_PlayModeDispatch(void);
extern void AccompSeq_StopSequence(void);
extern void MidiChannel_ResetAndConfigure(void);
extern void UI_PostTimerResetEvent(void);
extern void Demo_SelectEntry_AfterSongLoad(void);
void SeqPlay_StopAndResetAll(void)
{
  unsigned char a, f;
  if (SEQ_PLAY_FLAGS & 0x01) {
    if (SEQ_REC_TRACKS == 0) ram_22f6 = 0;
    return;
  }
  a = ACC_TRANSPORT_STATE;
  if (!(a & 0x08) && (a & 0x04)) {
    if (!(SEQ_TRANSPORT_STATE & 0x04)) return;
    AccWrap_PlayModeStopExpr();
    ram_22f6 = 0;
  } else AccWrap_PlayModeDispatch();
  SEQ_CONTROL_FLAGS &= ~0x20;
  SeqBuf_WriteNoteOffEntry(0x32);
  NoteMap_SendAllNotesOff();
  AudioInit_RefreshToneBank();
  VoiceAlloc_ProcessAll();
  AccompSeq_StopSequence();
  ram_2892 &= ~0x80;
  MidiChannel_ResetAndConfigure();
  SEQ_RTMCFG &= ~0x08;
  SEQ_START_MEASURE = 1;
  SEQ_ACTIVE_PARTS = 0;
  f = SEQ_CONTROL_FLAGS;
  f |= 0x10;
  f |= 0x04;
  SEQ_CONTROL_FLAGS = f;
  ram_22f6 = 0;
  if (CURRENT_MODE == 19) {
    SEQ_TRACK_MASK = 0;
    Audio_CheckSubsystemReady();
    SEQ_ACTIVE_PARTS = 0;
    UI_PostTimerResetEvent();
    Demo_SelectEntry_AfterSongLoad();
  }
}
