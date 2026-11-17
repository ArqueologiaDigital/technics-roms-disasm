/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FileIO_SeekAndRead16BitValue NotePool_InsertEntry SeqAcc_InitPlayback_FreshStart SeqPlay_CheckDrumPartAndClearCounters SeqPlay_ReactivatePartsAndResume SeqPlay_RestartWithVoiceConfig */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern unsigned char SeqAcc_InitPlaybackState(void);

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
