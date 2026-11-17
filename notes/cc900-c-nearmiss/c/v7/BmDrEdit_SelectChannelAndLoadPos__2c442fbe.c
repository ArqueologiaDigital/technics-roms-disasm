/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of v7/bmdredit_routines_m232.c (2026-11-16-111-p6-r22-staged)
   sha256 2c442fbe559902db6d1bb616a5f0a05ab1d09ee762bbda8ebc02d696d6663aa6 (tar-sha256); compiled at -O3 -Xr */
/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_ApplyVelocityChange BmDrEdit_CheckAndSelectChannel BmDrEdit_ClearAndScanToEnd BmDrEdit_CopyEventDataBetweenParts BmDrEdit_CountMeasuresInit BmDrEdit_InitCommon BmDrEdit_RefreshDisplayState BmDrEdit_SaveSongPosition BmDrEdit_SeekForwardToEvent BmDrEdit_SyncChannelAndGetPos BmDrEdit_ValidateAndProcessVoice NoteEditSy_ScanAndSortEntries */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_2742;
extern void BmDrEdit_InitCommon(void);
extern unsigned int __near ram_2792;
extern unsigned int __near ram_2794;
extern unsigned int __near ram_278e;
extern unsigned int __near ram_2790;
extern unsigned char __near ram_2774;
extern unsigned char __near ram_27a2;
extern void BmDrEdit_InitMelodicMode(void);
extern void NoteEditSy_ScanAndSortEntries(void);
extern unsigned char *__cdecl Malloc(unsigned int);
typedef unsigned char *ucp;
extern ucp __near ram_1d50;
extern ucp __near ram_1d54;
extern unsigned int __near ram_2796;
extern void BmDrEdit_InitDrumMode(void);
extern unsigned int __near ram_275e;
extern unsigned int __near ram_276a;
extern unsigned char __near ram_2760;
extern unsigned char __near ram_276c;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near ram_276e;
extern unsigned char __near ram_2770;
extern unsigned int __near SEQ_DATA_OFFSET;
extern void BmDrEdit_LoadAlternateState(void);
extern unsigned int __near ram_2808;
extern unsigned int __near ram_280a;
extern unsigned int __near ram_27ba;
extern unsigned int __near ram_27bc;
extern unsigned char __near ram_2806;
extern unsigned int __near ram_27be;
extern unsigned int __near ram_27c0;
extern unsigned int BmDrEdit_RenderVertical_Table[], BmDrEdit_RenderHorizontal_Table[];
extern void BmDrEdit_RenderHorizontal(void);
extern void BmDrEdit_RenderVertical(void);
extern unsigned int BmDrEdit_SyncChannelAndGetPos(void);
extern unsigned char __near SEQ_ERROR_CODE;
extern void BmDrEdit_SelectChannelAndLoadPos(void);
extern unsigned char BmDrEdit_CheckAndSelectChannel(void);
extern void BmDrEdit_ValidateAndProcessVoice(unsigned int, unsigned int, unsigned int *);
extern unsigned int __near ram_287f;
extern unsigned int __near ram_2744;
extern unsigned char __near BMDREDIT_CHANNEL;

void BmDrEdit_InitMelodicMode(void)
{
	ram_2792 = ram_2794;
	ram_278e = ram_2790;
	ram_2742 &= ~1;
	ram_2774 = 10;
	ram_27a2 = 11;
	BmDrEdit_InitCommon();
}

void BmDrEdit_InitDrumMode(void)
{
	ram_1d54 = ram_1d50 = Malloc(0x6a4);
	NoteEditSy_ScanAndSortEntries();
	ram_278e = 10;
	ram_2792 = ram_2796;
	ram_2742 |= 1;
	ram_2774 = 7;
	ram_27a2 = 8;
	BmDrEdit_InitCommon();
}

void BmDrEdit_LoadAlternateState(void)
{
	ram_275e = ram_276a;
	ram_2760 = ram_276c;
	SEQ_DATA_BLOCK = ram_276e;
	SEQ_DATA_OFFSET = ram_2770;
}

void BmDrEdit_RenderHorizontal(void)
{
	ram_27ba = (ram_2808 >> 2) + 0x16;
	ram_27bc = (ram_280a >> 2) + ram_27ba;
	ram_27be = BmDrEdit_RenderHorizontal_Table[ram_2806];
	ram_27c0 = ram_27be + 3;
}

void BmDrEdit_RenderVertical(void)
{
	ram_27ba = (ram_2808 >> 2) + 0x5b;
	ram_27bc = (ram_280a >> 2) + ram_27ba;
	ram_27be = BmDrEdit_RenderVertical_Table[ram_2806];
	ram_27c0 = ram_27be + 3;
}

void BmDrEdit_SelectChannelAndLoadPos(void)
{
	unsigned int h;

	SEQ_ERROR_CODE = 0;
	h = BmDrEdit_SyncChannelAndGetPos();
	if (SEQ_ERROR_CODE != 0) return;
	ram_276a = h;
	ram_276c = 0;
	ram_276e = SEQ_DATA_BLOCK;
	ram_2770 = SEQ_DATA_OFFSET;
}

unsigned int BmDrEdit_SyncChannelAndGetPos(void)
{
	unsigned int r;
	unsigned char h;

	ram_287f = ram_2744;
	h = BmDrEdit_CheckAndSelectChannel();
	BmDrEdit_ValidateAndProcessVoice((unsigned char)(BMDREDIT_CHANNEL + 1), h, &r);
	return r;
}
