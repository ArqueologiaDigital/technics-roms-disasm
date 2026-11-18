/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_2m269a.c (2026-11-18-28-p6-r36)
   sha256 ff1cfd90ffa270224390ac49cc7ea7c49764991412ed0ee6b6a9b56075c508e7 (tar-sha256); compiled at -O3 -Xr
   cc900-name: SLSrc_ComposerDrawPatternSlot=SingleLoadSrc_ComposerDrawPatternSlot
   cc900-name: SL_GetComposerSectionName=SingleLoad_GetComposerSectionName
   cc900-name: SlSrcEntry_Str_ALL=SLSrcBankList_FuncBody_Entry_Str_ALL
   cc900-name: SlSrcEntry_Str_Colon_2=SLSrcBankList_FuncBody_Entry_Str_Colon_2
   cc900-name: SlSrcEntry_Str_Colon_3=SLSrcBankList_FuncBody_Entry_Str_Colon_3 */
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
extern char *SingleLoad_GetVariationName(unsigned int);
extern void SL_GetComposerSectionName(char *, unsigned int, unsigned int, int);
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
	} else {
		if (v < 4)
			return;
		SL_GetComposerSectionName(q, SLOAD_SRC_CMP_POS / n, v, 3);
	}
	ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_SRC_ROWS + 63));
}
