/* Phase 6, lane_p6 helper D, round 14, module 232 (v10 sequencer/bmdredit_routines.s): routines with
   memory-to-memory moves.  The moved cells are __near (V4.23 then moves them itself); TT_SQDRMEDT is 0x98 and
   TT_SQNOTEEDT 0x95. */
/* cc900-module: BmDrEdit_CheckAndSelectChannel BmDrEdit_InitCommon BmDrEdit_SyncChannelAndGetPos BmDrEdit_ValidateAndProcessVoice NoteEditSy_ScanAndSortEntries */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char BmDrEdit_CheckAndSelectChannel(void);
extern void BmDrEdit_ValidateAndProcessVoice(unsigned int, unsigned int, unsigned int *);
extern unsigned int BmDrEdit_SyncChannelAndGetPos(void);
extern void UI_ChangeTitleByIndex(unsigned int);
extern void SeqVoice_FindSingleActive(void);
extern void NoteEditSy_ScanAndSortEntries(void);
extern void BmDrEdit_InitCommon(void);
extern unsigned char *__cdecl Malloc(unsigned int);

typedef unsigned char *ucp;

extern unsigned int __near ram_275e;
extern unsigned int __near ram_276a;
extern unsigned char __near ram_2760;
extern unsigned char __near ram_276c;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near ram_276e;
extern unsigned char __near ram_2770;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near ram_287f;
extern unsigned int __near ram_2744;
extern unsigned char __near BMDREDIT_CHANNEL;
extern unsigned char __near ram_2742;
extern unsigned int __near ram_2963;
extern unsigned int __near ram_d4f;
extern unsigned char __near ram_1d58;
extern unsigned char __near PART_SELECT;
extern ucp __near ram_1d50;
extern ucp __near ram_1d54;
extern unsigned int __near ram_278e;
extern unsigned int __near ram_2792;
extern unsigned int __near ram_2796;
extern unsigned char __near ram_2774;
extern unsigned char __near ram_27a2;
extern unsigned int __near ram_2808;
extern unsigned int __near ram_280a;
extern unsigned int __near ram_27ba;
extern unsigned int __near ram_27bc;
extern unsigned char __near ram_2806;
extern unsigned int __near ram_27be;
extern unsigned int __near ram_27c0;
extern unsigned int BmDrEdit_RenderVertical_Table[], BmDrEdit_RenderHorizontal_Table[];

void BmDrEdit_LoadAlternateState(void)
{
	ram_275e = ram_276a;
	ram_2760 = ram_276c;
	SEQ_DATA_BLOCK = ram_276e;
	SEQ_DATA_OFFSET = ram_2770;
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

void BmDrEdit_SaveSequencerState(void)
{
	UI_ChangeTitleByIndex((ram_2742 & 1) ? 0x98 : 0x95);
	ram_2963 = ram_d4f;
	SeqVoice_FindSingleActive();
	ram_1d58 = PART_SELECT;
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

void BmDrEdit_RenderVertical(void)
{
	ram_27ba = (ram_2808 >> 2) + 0x5b;
	ram_27bc = (ram_280a >> 2) + ram_27ba;
	ram_27be = BmDrEdit_RenderVertical_Table[ram_2806];
	ram_27c0 = ram_27be + 3;
}

void BmDrEdit_RenderHorizontal(void)
{
	ram_27ba = (ram_2808 >> 2) + 0x16;
	ram_27bc = (ram_280a >> 2) + ram_27ba;
	ram_27be = BmDrEdit_RenderHorizontal_Table[ram_2806];
	ram_27c0 = ram_27be + 3;
}
