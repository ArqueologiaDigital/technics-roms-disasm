/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_BuildNoteOnEvent_WithVelocity BmDrEdit_CheckChannelActive BmDrEdit_CountMeasuresAndValidate BmDrEdit_DelayAction_PlayClick BmDrEdit_IncrementDuration BmDrEdit_LoadAlternateState BmDrEdit_SelectActiveChannel BmDrEdit_SendMetronomeNoteOn Metronome_PlayClick NoteEditSy_UpdateAllWidgets SeqAcc_HandlePlaybackTick SeqAcc_InitAndDispatch SeqAcc_SetupRepeatCount */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near SEQ_SONG_RECORD[];
extern void SeqAcc_SetupRepeatCount(void);
extern void SeqAcc_HandlePlaybackTick(void);
extern void CtrlPanel_SetIndicatorBit(unsigned int);
extern void SeqPlay_SaveStateAndCleanup(void);
extern void SeqAcc_StopPlayback(void);
extern void Accomp_UpdateModeFlag(void);
extern void SeqAcc_InitAndDispatch(void);
extern void SeqAcc_UpdateAndDispatch(void);

void SeqAcc_StopPlayback(void)
{
  if (CURRENT_TITLE != 136) {
    SEQ_SONG_RECORD[188] &= ~0x01;
    SeqAcc_SetupRepeatCount();
  }
  SeqAcc_HandlePlaybackTick();
  CtrlPanel_SetIndicatorBit(0x4c);
  SeqPlay_SaveStateAndCleanup();
}

void SeqAcc_UpdateAndDispatch(void)
{
  Accomp_UpdateModeFlag();
  SeqAcc_InitAndDispatch();
}
