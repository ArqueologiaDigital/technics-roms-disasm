/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -XS -Xr
*/
/* cc900-module: SeqModeTransit_DemoPath SeqModeTransit_UpdateParts SeqPart_InitClear SeqPart_UndoAllocOnError */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned int __near ram_f1ce;
extern void Audio_CheckSubsystemReady(void);
extern void SeqData_CopyBlockToBuffer(unsigned int);
extern void VoicePreset_LoadAndInitPan(unsigned int);
/* cc900-name: SeqVoice_InitEntryCurBank=SeqVoice_InitEntryForCurrentBank */
extern void SeqVoice_InitEntryCurBank(void);
extern void SeqStep_FindAndCompact(void);
extern void SingleLoad_PrepareSongSlot(unsigned char a);

void SingleLoad_PrepareSongSlot(unsigned char a)
{
  unsigned int k;
  SEQ_TRACK_MASK = SEQ_TRACK_MASK_COPY;
  Audio_CheckSubsystemReady();
  SeqData_CopyBlockToBuffer(SEQ_CURRENT_SONG);
  VoicePreset_LoadAndInitPan(a);
  SEQ_CURRENT_SONG = a;
  SeqVoice_InitEntryCurBank();
  SeqData_CopyBlockToBuffer(SEQ_CURRENT_SONG);
  k = ram_f1ce;
  SeqStep_FindAndCompact();
  ram_f1ce = k;
}
