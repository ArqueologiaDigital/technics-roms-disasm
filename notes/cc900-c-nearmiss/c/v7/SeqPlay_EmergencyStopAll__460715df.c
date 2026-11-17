/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine.c (2026-11-16-45-p6-r9)
   sha256 460715dffc082e8fb1117540a96c16bf1d1dc19c2d65230f3d922f38ac2ad536 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_28a6;
extern unsigned char __near ram_2310;
extern unsigned int __near SEQ_TRACK_MASK;
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
