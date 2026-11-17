/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_13m269b.c (2026-11-16-100-p6-r19)
   sha256 eb69b8d543cab96b31850bf692333ef49a4366d8c49ec500d825511a483b5645 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-name: SlDst_Str_Colon=SLDstBankList_FuncBody_Str_Colon */
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern void SingleLoad_GetFileBankName(char *, unsigned int, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_DST_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SLOAD_DST_PMEM_POS;
extern char *StorageArea_UnitNames[], *SingleLoad_BankCaptionByMode[];
extern char SlDst_Str_Colon[];
void SLDstBankList_FuncBody(long obj, unsigned char n)
{
	char *p;

	p = SINGLE_LOAD_DST_ROWS;
	*p = 0;
	FileIO_CopyString(p + 1,SingleLoad_BankCaptionByMode[SINGLE_LOAD_AREA] + 1);
	FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 1, SlDst_Str_Colon);
	FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 1, NumToAscii_FormatNumber((unsigned char)(SLOAD_DST_PMEM_POS / n + 1), 0));
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_DST_ROWS + 1, 16);
	SingleLoad_GetFileBankName(SINGLE_LOAD_DST_ROWS + 21, SLOAD_DST_PMEM_POS / n, 1);
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_DST_ROWS + 22, 16);
	ApPostEvent(obj, 0x1c0000fL, 0x89a2L);
	ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_DST_ROWS + 21));
}
