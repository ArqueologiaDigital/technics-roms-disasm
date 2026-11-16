/* Functions of file_io/single_load.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: NumToAscii_FormatNumber SingleLoad_GetFileBankName TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern void SingleLoadSrc_PanelMemDrawMemoryNumber(long obj, unsigned char n);
extern void SingleLoad_GetFileBankName(char *, unsigned int, unsigned int);
extern char __near SINGLE_LOAD_DST_ROWS[];
extern unsigned char __near SLOAD_DST_PMEM_POS;
extern char SlDst_Str_Colon[];
extern void SLDstBankList_FuncBody(long obj, unsigned char n);

/* cc900-name: SlSrc_Str_Colon_2=SLSrcBankList_FuncBody_Str_Colon_2 */
/* cc900-name: SlSrcEntry_Str_Colon_5=SLSrcBankList_FuncBody_Entry_Str_Colon_5 */
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

/* cc900-name: SlDst_Str_Colon=SLDstBankList_FuncBody_Str_Colon */
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
