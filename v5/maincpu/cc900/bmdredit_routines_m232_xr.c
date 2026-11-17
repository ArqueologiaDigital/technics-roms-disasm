/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: BmDrEdit_ApplyVelocityChange BmDrEdit_ClearAndScanToEnd BmDrEdit_CopyEventDataBetweenParts BmDrEdit_CountMeasuresInit BmDrEdit_InitCommon BmDrEdit_RefreshDisplayState BmDrEdit_SaveSongPosition BmDrEdit_SeekForwardToEvent */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void UI_ChangeTitleByIndex(unsigned int);
extern void SeqVoice_FindSingleActive(void);
extern unsigned char __near ram_2728;
extern unsigned int __near ram_2947;
extern unsigned int __near ram_d4f;
extern unsigned char __near ram_1d54;
extern unsigned char __near PART_SELECT;
extern void BmDrEdit_SaveSequencerState(void);

void BmDrEdit_SaveSequencerState(void)
{
	unsigned int k;

	if (ram_2728 & 1) k = 0x98;
	else k = 0x95;
	UI_ChangeTitleByIndex(k);
	ram_2947 = ram_d4f;
	SeqVoice_FindSingleActive();
	ram_1d54 = PART_SELECT;
}

/* cc900-module: BmDrEdit_CheckAndSelectChannel BmDrEdit_InsertStepEntry BmDrEdit_ProcessVoiceSection BmDrEdit_RestoreEditState BmDrEdit_SaveEditState BmDrEdit_SetupScrollRegion EditChannel_LoadVoiceParams */
extern void NoteEditSy_UpdateChordDisplay(void);
extern void BmDrEdit_SetupScrollRegion(unsigned char *, unsigned char *);
extern unsigned char __near ram_2946;
extern unsigned char __near ram_27b0;
extern unsigned char __near NOTEEDIT_BASE_KEY;
extern void BmDrEdit_AdjustScrollToView(void);

void BmDrEdit_AdjustScrollToView(void)
{
	unsigned char lo, hi;
	unsigned char c, k;

	if (ram_2728 & 1) return;
	ram_27b0 = NOTEEDIT_BASE_KEY;
	for (;;) {
		BmDrEdit_SetupScrollRegion(&lo, &hi);
		c = ram_2946;
		k = NOTEEDIT_BASE_KEY;
		if (c < lo) {
			c = k;
			if (k == 0) return;
			c--;
			NOTEEDIT_BASE_KEY = c;
		} else if (c > hi) {
			c = k;
			if (k >= 9) return;
			c++;
			NOTEEDIT_BASE_KEY = c;
		} else
			break;
	}
	if (ram_27b0 == NOTEEDIT_BASE_KEY) return;
	NoteEditSy_UpdateChordDisplay();
}
