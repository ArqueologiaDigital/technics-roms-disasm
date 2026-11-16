/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of v5/bmdredit_routines_m232.c (2026-11-16-111-p6-r22-staged)
   sha256 08d180327d39612b36806070e17419d5ff27e6973cb45f2ed75fb40b17d07ac7 (tar-sha256); compiled at -O3 -Xr */
/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_ApplyVelocityChange BmDrEdit_CheckAndSelectChannel BmDrEdit_ClearAndScanToEnd BmDrEdit_CopyEventDataBetweenParts BmDrEdit_CountMeasuresInit BmDrEdit_InitCommon BmDrEdit_RefreshDisplayState BmDrEdit_SaveSongPosition BmDrEdit_SeekForwardToEvent BmDrEdit_SyncChannelAndGetPos BmDrEdit_ValidateAndProcessVoice NoteEditSy_ScanAndSortEntries */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_2728;
extern void BmDrEdit_InitCommon(void);
extern unsigned int __near ram_2778;
extern unsigned int __near ram_277a;
extern unsigned int __near ram_2774;
extern unsigned int __near ram_2776;
extern unsigned char __near ram_275a;
extern unsigned char __near ram_2788;
extern void BmDrEdit_InitMelodicMode(void);
extern unsigned int __near ram_2744;
extern unsigned int __near ram_2750;
extern unsigned char __near ram_2746;
extern unsigned char __near ram_2752;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near ram_2754;
extern unsigned char __near ram_2756;
extern unsigned int __near SEQ_DATA_OFFSET;
extern void BmDrEdit_LoadAlternateState(void);
extern unsigned int __near ram_27ee;
extern unsigned int __near ram_27f0;
extern unsigned int __near ram_27a0;
extern unsigned int __near ram_27a2;
extern unsigned char __near ram_27ec;
extern unsigned int __near ram_27a4;
extern unsigned int __near ram_27a6;
extern unsigned int BmDrEdit_RenderVertical_Table[], BmDrEdit_RenderHorizontal_Table[];
extern void BmDrEdit_RenderHorizontal(void);
extern void BmDrEdit_RenderVertical(void);
extern unsigned int BmDrEdit_SyncChannelAndGetPos(void);
extern unsigned char __near SEQ_ERROR_CODE;
extern void BmDrEdit_SelectChannelAndLoadPos(void);
extern unsigned char BmDrEdit_CheckAndSelectChannel(void);
extern void BmDrEdit_ValidateAndProcessVoice(unsigned int, unsigned int, unsigned int *);
extern unsigned int __near ram_2863;
extern unsigned int __near ram_272a;
extern unsigned char __near BMDREDIT_CHANNEL;

void BmDrEdit_InitMelodicMode(void)
{
	ram_2778 = ram_277a;
	ram_2774 = ram_2776;
	ram_2728 &= ~1;
	ram_275a = 10;
	ram_2788 = 11;
	BmDrEdit_InitCommon();
}


void BmDrEdit_LoadAlternateState(void)
{
	ram_2744 = ram_2750;
	ram_2746 = ram_2752;
	SEQ_DATA_BLOCK = ram_2754;
	SEQ_DATA_OFFSET = ram_2756;
}

void BmDrEdit_RenderHorizontal(void)
{
	ram_27a0 = (ram_27ee >> 2) + 0x16;
	ram_27a2 = (ram_27f0 >> 2) + ram_27a0;
	ram_27a4 = BmDrEdit_RenderHorizontal_Table[ram_27ec];
	ram_27a6 = ram_27a4 + 3;
}

void BmDrEdit_RenderVertical(void)
{
	ram_27a0 = (ram_27ee >> 2) + 0x5b;
	ram_27a2 = (ram_27f0 >> 2) + ram_27a0;
	ram_27a4 = BmDrEdit_RenderVertical_Table[ram_27ec];
	ram_27a6 = ram_27a4 + 3;
}

void BmDrEdit_SelectChannelAndLoadPos(void)
{
	unsigned int h;

	SEQ_ERROR_CODE = 0;
	h = BmDrEdit_SyncChannelAndGetPos();
	if (SEQ_ERROR_CODE != 0) return;
	ram_2750 = h;
	ram_2752 = 0;
	ram_2754 = SEQ_DATA_BLOCK;
	ram_2756 = SEQ_DATA_OFFSET;
}

unsigned int BmDrEdit_SyncChannelAndGetPos(void)
{
	unsigned int r;
	unsigned char h;

	ram_2863 = ram_272a;
	h = BmDrEdit_CheckAndSelectChannel();
	BmDrEdit_ValidateAndProcessVoice((unsigned char)(BMDREDIT_CHANNEL + 1), h, &r);
	return r;
}
