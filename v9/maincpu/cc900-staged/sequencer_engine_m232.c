/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_CheckAndAdvancePage BmDrEdit_LoadAlternateState BmDrEdit_RefreshDisplayState BmDrEdit_ScanChannelEvents BmDrEdit_SeekToPartVoice BmDrEdit_SelectChannelAndLoadPos BmDrEdit_SendMetronomeNoteOn BmDrEdit_SetupAndWalkToNote BmDrEdit_SkipToEventByCount BmDrEdit_SyncSeekCheck NoteEditSy_SendCompoundWidgetUpdate NoteEdit_SendScrollCmds NoteEdit_UpdateScrollAndDisplay SeqAcc_SetupRepeatCount SeqAcc_UpdateEndPosition */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near SEQ_METRO_FLAGS;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near ram_26ec;
extern unsigned int __near SEQ_PUNCH_IN_MEASURE;
extern unsigned int __near SEQ_COUNT_IN;
extern unsigned int __near ram_28c3;
extern void SeqAcc_UpdateEndPosition(void);
extern void SeqAcc_SetupRepeatCount(void);
extern void SeqPlay_IncPunchCountIn(void);

void SeqPlay_IncPunchCountIn(void)
{
	unsigned int c;

	if ((SEQ_METRO_FLAGS & 0x01) && SEQ_PUNCH_IN_MEASURE <= 2)
		return;
	c = SEQ_COUNT_IN;
	if (c >= 997)
		SEQ_COUNT_IN = 997;
	else
		SEQ_COUNT_IN = c + 1;
	ram_28c3 = SEQ_PUNCH_IN_MEASURE - 1;
	SeqAcc_UpdateEndPosition();
	ram_26ec = SEQ_START_MEASURE = SEQ_PUNCH_IN_MEASURE - SEQ_COUNT_IN;
	SeqAcc_SetupRepeatCount();
}
