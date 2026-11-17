/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m233.c (2026-11-17-1-p6-r28-staged)
   sha256 8e2a1ca167da83d2ab9d9518bacb02eece81fb5170c0c3082cc2b576fba92902 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_22fc;
extern unsigned char __near ram_1d92;
extern unsigned int __near ram_2316;
extern unsigned char __near ram_231c;
extern unsigned char __near ram_231e;
extern unsigned char __near ram_2320;
extern unsigned char __near ram_2322;
extern unsigned char __near ram_2324;
extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned char __near ram_45b;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near ACC_RUN_FLAGS;
extern unsigned char __near ram_28ac;
extern unsigned char __near SEQ_CHORD_FROM_SONG;
extern void SeqNotePool_Init(unsigned int);
extern unsigned char SeqPlay_CheckRepeatActive(void);
extern unsigned char Part_FindVoiceByByte(unsigned int, unsigned int);
extern void BitMapOut_PrepareAndDisplay(void);
extern void BitMapOut_PrepareAndDisplaySimple(void);
extern void SeqAcc_InitPlayback_FreshStart(void);
extern void SeqPlay_RestartWithVoiceConfig(void);
extern void SeqPlay_CheckDrumPartAndClearCounters(void);
extern void SeqPlay_ResetStartState(void);
unsigned char SeqAcc_InitPlaybackState(void)
{
  SEQ_CONTROL_FLAGS &= ~0x20;
  SeqNotePool_Init(0x32);
  ram_45b &= ~0x01;
  ram_1d92 = SeqPlay_CheckRepeatActive();
  if (SEQ_TRACK_MASK == 0) {
    if (SEQ_REC_TRACKS != 0) goto clear;
    SEQ_RTMCFG = (SEQ_RTMCFG & ~0x01) | 0x02;
    goto state0;
  }
  if (ACC_RUN_FLAGS & 0x02) {
    SEQ_CONTROL_FLAGS |= 0x10;
    return 0;
  }
  ram_231c = Part_FindVoiceByByte(0, 0x0d);
  ram_231e = Part_FindVoiceByByte(0, 0x10);
  ram_2320 = Part_FindVoiceByByte(0, 0x0c);
  ram_2322 = Part_FindVoiceByByte(0, 0x0e);
  ram_2324 = Part_FindVoiceByByte(0, 0x0f);
  BitMapOut_PrepareAndDisplay();
  BitMapOut_PrepareAndDisplaySimple();
  ram_28ac |= 0x10;
  if ((SEQ_RTMCFG & 0x08) == 0) SeqAcc_InitPlayback_FreshStart();
  else SeqPlay_RestartWithVoiceConfig();
  ram_28ac &= ~0x10;
  if (ram_2316 == 0) {
    if (SEQ_REC_TRACKS != 0) goto clear;
state0:
    ram_22fc = 0;
clear:
    SEQ_CHORD_FROM_SONG = 0;
  } else {
    SeqPlay_CheckDrumPartAndClearCounters();
    if (SEQ_REC_TRACKS == 0) {
      if (ram_1d92 == 0) ram_22fc = 1;
      else ram_22fc = 4;
    }
  }
  SeqPlay_ResetStartState();
  return 0;
}
