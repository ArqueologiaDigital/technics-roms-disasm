/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/single_load_m269.c (2026-11-18-33-p6-r37)
   sha256 96302b8e8900793f392e4fa596ab3da5b57658f9545211855db62a644bc69b80 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr
   cc900-name: SLSrc_ComposerDrawBankName=SingleLoadSrc_ComposerDrawBankName
   cc900-name: SlSrcEntry_Str_ALL=SLSrcBankList_FuncBody_Entry_Str_ALL
   cc900-name: SlSrcEntry_Str_Colon_2=SLSrcBankList_FuncBody_Entry_Str_Colon_2
   cc900-name: SlSrcEntry_Str_Colon_3=SLSrcBankList_FuncBody_Entry_Str_Colon_3 */
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SLOAD_SRC_CMP_POS;
extern char *StorageArea_UnitNames[], *SingleLoad_BankCaptionByMode[];
extern char SlSrcEntry_Str_Colon_2[], SlSrcEntry_Str_Colon_3[], SlSrcEntry_Str_ALL[];
extern void SingleLoad_GetComposerBankName(char *, unsigned int, unsigned int);
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
