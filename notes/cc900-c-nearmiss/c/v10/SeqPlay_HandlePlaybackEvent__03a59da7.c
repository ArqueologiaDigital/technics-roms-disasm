/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m233.c (2026-11-16-81-p6-r14)
   sha256 03a59da74701137c4ff683e4feac4ce7527f6e656c7ab2be79acb7041867c8af (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeqSyncPosMidiTiming=Seq_SyncPositionAndOutputMIDITiming */
extern unsigned char __near ram_28a6;
extern unsigned int __near SEQ_TRACK_MASK;
extern void Audio_CheckSubsystemReady(void);
extern void SeqBuf_WriteNoteOffEntry(int);
extern void NoteMap_SendAllNotesOff(void);
extern void AudioInit_RefreshToneBank(void);
extern void VoiceAlloc_ProcessAll(void);
extern unsigned char __near SEQ_RTMCFG;
extern unsigned int __near SEQ_ACTIVE_PARTS;
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near ram_28ae;
extern void AccompSeq_StopSequence(void);
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
