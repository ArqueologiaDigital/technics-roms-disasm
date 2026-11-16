/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine.c (2026-11-16-45-p6-r9)
   sha256 5b43ccb0f5f0b0c86ae6214de92ae9d1c1dc1d567f7e9d57a09f52f4b38b93c5 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_288a;
extern unsigned char __near ram_230a;
extern unsigned int __near SEQ_TRACK_MASK;
void SeqPlay_EmergencyStopAll(void)
{
  if (ram_230a != 0) return;
  ram_230a = 1;
  SEQ_TRACK_MASK = 0;
  Audio_CheckSubsystemReady();
  AccWrap_PositionClear();
  ram_288a &= ~0x01;
  SeqBuf_WriteNoteOffEntry(0x32);
  NoteMap_SendAllNotesOff();
  AudioInit_RefreshToneBank();
  VoiceAlloc_ProcessAll();
  BitMapOut_PrepareAndDisplay();
  ram_230a = 0;
}
