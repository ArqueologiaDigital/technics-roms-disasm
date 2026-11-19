/* lane_p6 round 3 (2026-11-19): p6_J_2m269a.c (r36: PatternSlot +138, O3Xr) with the last ApPostEvent written in each
   branch: the ROM repeats its argument setup per branch and shares only the call (V4.23 shared the whole tail).
   Original notes follow.
   Phase 6, lane_p6 helper J, round 2, module 269 (file_io/single_load.s, -O3 -Xr like single_load_m269.c), form a:
   SingleLoadSrc_ComposerDrawBankName and SingleLoadSrc_ComposerDrawPatternSlot, the composer twins of the matched
   SingleLoadSrc_PanelMemDrawMemoryNumber / SLDstBankList_FuncBody. */
/* cc900-name: SlSrcEntry_Str_Colon_2=SLSrcBankList_FuncBody_Entry_Str_Colon_2 */
/* cc900-name: SlSrcEntry_Str_Colon_3=SLSrcBankList_FuncBody_Entry_Str_Colon_3 */
/* cc900-name: SlSrcEntry_Str_ALL=SLSrcBankList_FuncBody_Entry_Str_ALL */
/* cc900-name: SL_GetComposerSectionName=SingleLoad_GetComposerSectionName */
/* cc900-name: SLSrc_ComposerDrawPatternSlot=SingleLoadSrc_ComposerDrawPatternSlot */
/* cc900-name: SLSrc_ComposerDrawBankName=SingleLoadSrc_ComposerDrawBankName */
/* cc900-module: SingleLoad_GetComposerBankName SingleLoad_GetComposerSectionName SingleLoad_GetVariationName TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near SLOAD_SRC_CMP_POS;
extern char *StorageArea_UnitNames[], *SingleLoad_BankCaptionByMode[];
extern char SlSrcEntry_Str_Colon_2[], SlSrcEntry_Str_Colon_3[], SlSrcEntry_Str_ALL[];
extern void SingleLoad_GetComposerBankName(char *, unsigned int, unsigned int);
extern char *SingleLoad_GetVariationName(unsigned int);
extern void SL_GetComposerSectionName(char *, unsigned int, unsigned int, int);

void SLSrc_ComposerDrawBankName(long obj, unsigned char n)
{
	char *p;

	p = SINGLE_LOAD_SRC_ROWS;
	*p = 0;
	FileIO_CopyString(p + 1, SingleLoad_BankCaptionByMode[SINGLE_LOAD_AREA] + 1);
	FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 1, SlSrcEntry_Str_Colon_2);
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 1, 16);
	SingleLoad_GetComposerBankName(SINGLE_LOAD_SRC_ROWS + 21, SLOAD_SRC_CMP_POS / n, 1);
	ApPostEvent(obj, 0x1c0000fL, 0x894eL);
	ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_SRC_ROWS + 21));
}

void SLSrc_ComposerDrawPatternSlot(long obj, unsigned char n)
{
	unsigned int v;
	char *p;
	char *q;

	v = SLOAD_SRC_CMP_POS % n;
	p = SINGLE_LOAD_SRC_ROWS;
	p[42] = 2;
	FileIO_CopyString(p + 43, StorageArea_UnitNames[SINGLE_LOAD_AREA] + 1);
	FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 43, SlSrcEntry_Str_Colon_3);
	if (SINGLE_LOAD_ALL == 0)
		FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 43, SingleLoad_GetVariationName(v));
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 43, 16);
	ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_SRC_ROWS + 42));
	p = SINGLE_LOAD_SRC_ROWS;
	q = p + 63;
	if (SINGLE_LOAD_ALL != 0) {
		*q = 3;
		FileIO_CopyString(p + 64, SlSrcEntry_Str_ALL);
		ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_SRC_ROWS + 63));
	} else {
		if (v < 4)
			return;
		SL_GetComposerSectionName(q, SLOAD_SRC_CMP_POS / n, v, 3);
		ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_SRC_ROWS + 63));
	}
}
