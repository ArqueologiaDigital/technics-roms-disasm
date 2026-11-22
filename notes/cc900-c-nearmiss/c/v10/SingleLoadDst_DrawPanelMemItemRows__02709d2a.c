/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_O_29r1m269a.c (2026-11-22-11-p6-r78)
   sha256 02709d2a00d16b10eaf4e88ab62f49455bd1dffba240070d82cabec3f1cb7453 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: SLDst_DrawPanelMemItemRows=SingleLoadDst_DrawPanelMemItemRows
   cc900-name: SlDst_Str_Colon_2=SLDstBankList_FuncBody_Str_Colon_2
   cc900-name: SlDst_Str_Colon_3=SLDstBankList_FuncBody_Str_Colon_3
   cc900-name: SlDst_Str_Colon_6=SLDstBankList_FuncBody_Str_Colon_6 */
#define EVT_PARA_DRAW      0x1c0000fL
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_DST_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near SLOAD_DST_PMEM_POS;
extern char *StorageArea_UnitNames[];
extern char SlDst_Str_Colon_2[], SlDst_Str_Colon_3[], SlDst_Str_Colon_6[], SLDstBankList_FuncBody_Str_ALL[];
extern char Str_AllOption_EA09B2[];
extern void SingleLoad_GetFileMemoryName(char *, unsigned int, unsigned int);
void SLDst_DrawPanelMemItemRows(long obj, unsigned char n)
{
	char *p;

	p = SINGLE_LOAD_DST_ROWS;
	p[42] = 2;
	p[63] = 3;
	if (SINGLE_LOAD_ALL != 0) {
		FileIO_CopyString(p + 43, StorageArea_UnitNames[SINGLE_LOAD_AREA] + 1);
		FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 43, SlDst_Str_Colon_2);
		TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_DST_ROWS + 43, 16);
		FileIO_CopyString(SINGLE_LOAD_DST_ROWS + 64, Str_AllOption_EA09B2);
	} else {
		FileIO_CopyString(p + 43, StorageArea_UnitNames[SINGLE_LOAD_AREA] + 1);
		FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 43, SlDst_Str_Colon_3);
		FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 43,
		                     NumToAscii_FormatNumber((unsigned char)(SLOAD_DST_PMEM_POS % n + 1), 0));
		TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_DST_ROWS + 43, 16);
		SingleLoad_GetFileMemoryName(SINGLE_LOAD_DST_ROWS + 63, SLOAD_DST_PMEM_POS, 3);
	}
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 42));
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 63));
}
