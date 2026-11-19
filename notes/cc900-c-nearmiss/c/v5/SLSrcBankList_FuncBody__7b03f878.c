/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/single_load_m269_b.c (2026-11-19-15-p6-r42)
   sha256 7b03f878aacba78b5aeb39bcff4fd9421f554aa9a564adbbc0911c2528dea2e2 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: SlSrc_Str_Colon=SLSrcBankList_FuncBody_Str_Colon */
#define EVT_PARA_DRAW           0x1c0000fL
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SLOAD_SRC_PMEM_POS;
extern char *SingleLoad_BankCaptionByMode[];
extern char SlSrc_Str_Colon[];
void SLSrcBankList_FuncBody(long obj, unsigned char n)
{
	char *p;

	p = SINGLE_LOAD_SRC_ROWS;
	*p = 0;
	FileIO_CopyString(p + 1, SingleLoad_BankCaptionByMode[SINGLE_LOAD_AREA] + 1);
	FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 1, SlSrc_Str_Colon);
	FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 1, NumToAscii_FormatNumber((unsigned char)(SLOAD_SRC_PMEM_POS / n + 1), 0));
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 1, 16);
	ApPostEvent(obj, EVT_PARA_DRAW, 0x894eL);
}
