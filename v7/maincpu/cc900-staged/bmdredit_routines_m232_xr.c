/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: BmDrEdit_ApplyVelocityChange BmDrEdit_ClearAndScanToEnd BmDrEdit_CopyEventDataBetweenParts BmDrEdit_CountMeasuresInit BmDrEdit_InitCommon BmDrEdit_RefreshDisplayState BmDrEdit_SaveSongPosition BmDrEdit_SeekForwardToEvent */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void UI_ChangeTitleByIndex(unsigned int);
extern void SeqVoice_FindSingleActive(void);
extern unsigned char __near ram_2742;
extern unsigned int __near ram_2963;
extern unsigned int __near ram_d4f;
extern unsigned char __near ram_1d58;
extern unsigned char __near PART_SELECT;
extern void BmDrEdit_SaveSequencerState(void);

void BmDrEdit_SaveSequencerState(void)
{
	unsigned int k;

	if (ram_2742 & 1) k = 0x98;
	else k = 0x95;
	UI_ChangeTitleByIndex(k);
	ram_2963 = ram_d4f;
	SeqVoice_FindSingleActive();
	ram_1d58 = PART_SELECT;
}
