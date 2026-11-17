/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_6a.c (2026-11-16-45-p6-r9)
   sha256 c6ba49e93845d47cb6db1d330d3125848a7d5054c2193ef4a34f5203cc1bc9c2 (tar-sha256); compiled at -O3 -Xr
   cc900-name: SeqSyncPosMidiTiming=Seq_SyncPositionAndOutputMIDITiming */
extern unsigned char __near SEQ_RTMCFG;
extern unsigned int __near SEQ_ACTIVE_PARTS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near ram_28ae;
extern unsigned char __near ram_28a6;
extern unsigned char __near ram_230a;
extern unsigned char __near ram_1d94;
extern unsigned int __near ram_2314;
extern unsigned char __near ram_431;
extern unsigned char __near ram_347a;
extern unsigned char __near ACC_LANES_ENDING1;
extern unsigned char __near ACC_LANES_ENDING2;
extern unsigned char __near ACC_LANES_ENDED;
extern void SeqBuf_WriteNoteOffEntry(int);
extern void NoteMap_SendAllNotesOff(void);
extern void AudioInit_RefreshToneBank(void);
extern void VoiceAlloc_ProcessAll(void);
extern void AccompSeq_StopSequence(void);
extern void Audio_CheckSubsystemReady(void);
extern void SeqAcc_ProcessTempoEvents(void);
extern void BitMapOut_PrepareAndDisplaySimple(void);
extern void SeqSyncPosMidiTiming(void);
extern void AccWrap_FullStop(void);
unsigned char SeqPlay_HandlePlaybackEvent(void)
{
  unsigned char a, e, c, t;
  if (CURRENT_TITLE == 0x87 || CURRENT_TITLE == 0x88) { SeqAcc_ProcessTempoEvents(); return 0; }
  a = ram_230a;
  if (a & 0x02) { a &= ~0x02; ram_230a = a; return 0; }
  ram_28ae &= ~0x80;
  ram_1d94 = 0;
  ram_2314 = SEQ_ACTIVE_PARTS;
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
        t = ram_347a;
        t |= 0x02;
        ram_347a = t;
      }
    }
    if (ram_28a6 & 0x01) { AccWrap_FullStop(); SEQ_RTMCFG |= 0x02; }
    SEQ_RTMCFG &= ~0x04;
  }
  return 0;
}
