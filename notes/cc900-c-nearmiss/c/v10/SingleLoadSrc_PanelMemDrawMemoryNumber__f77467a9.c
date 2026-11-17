/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/single_load_m269.c (2026-11-16-111-p6-r22-staged)
   sha256 f77467a936c3472e3010af7a0f9f7f638e985d20e25852f2642a55d0f5a027c0 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: SlSrcEntry_Str_Colon_5=SLSrcBankList_FuncBody_Entry_Str_Colon_5
   cc900-name: SlSrc_Str_Colon_2=SLSrcBankList_FuncBody_Str_Colon_2 */
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near SLOAD_SRC_PMEM_POS;
extern char *StorageArea_UnitNames[], *SingleLoad_BankCaptionByMode[];
extern char SlSrc_Str_Colon_2[], SlSrcEntry_Str_Colon_5[], SLSrcBankList_FuncBody_Str_ALL[], Str_AllOption_EA0980[];
void SingleLoadSrc_PanelMemDrawMemoryNumber(long obj, unsigned char n)
{
	char *p;

	p = SINGLE_LOAD_SRC_ROWS;
	p[42] = 2;
	FileIO_CopyString(p + 43, StorageArea_UnitNames[SINGLE_LOAD_AREA] + 1);
	FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 43, SlSrc_Str_Colon_2);
	if (SINGLE_LOAD_ALL == 0)
		FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 43,
		                     NumToAscii_FormatNumber((unsigned char)(SLOAD_SRC_PMEM_POS % n + 1), 0));
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 43, 16);
	ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_SRC_ROWS + 42));
	if (SINGLE_LOAD_ALL == 0) return;
	p = SINGLE_LOAD_SRC_ROWS;
	p[63] = 3;
	FileIO_CopyString(p + 64, SLSrcBankList_FuncBody_Str_ALL);
	ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_SRC_ROWS + 63));
}
