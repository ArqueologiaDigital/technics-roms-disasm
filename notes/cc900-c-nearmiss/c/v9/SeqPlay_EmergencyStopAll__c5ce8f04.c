/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine_m233.c (2026-11-16-91-p6-r17)
   sha256 c5ce8f0452a53a11166c6108fca3439ed8deb0cdb786c8f2d53a20b2e5ab9027 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
