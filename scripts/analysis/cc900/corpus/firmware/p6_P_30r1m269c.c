/* lane_p6 helper P, round 30r1, form c: module 269 (file_io/single_load.s), SingleLoadDst_DrawPanelMemItemRows.
   One-spot retry of helper O's p6_O_29r1m269b (run r78, Xr +27 / O3Xr +27: the unit-name source, which the ROM
   builds base first, `lda xhl, (StorageArea_UnitNames:24)`, the index scaled in BC, the destination (row + 43)
   computed in XWA BEFORE the table load, `ld xbc, (xhl+bc); inc 1, xbc`).  Form c: the table in a pointer local
   assigned first, the entry loaded, then the destination, then the source incremented on its own.
   cc900-options: -Xr
*/
/* cc900-module: NumToAscii_FormatNumber SingleLoad_GetFileMemoryName TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern char SlDst_Str_Colon_2[], SlDst_Str_Colon_3[];
extern char Str_AllOption_EA09B2[];
extern void SingleLoad_GetFileMemoryName(char *, unsigned int, unsigned int);
extern void SLDst_DrawPanelMemItemRows(long obj, unsigned char n);

/* cc900-name: SlDst_Str_Colon_2=SLDstBankList_FuncBody_Str_Colon_2 */
/* cc900-name: SlDst_Str_Colon_3=SLDstBankList_FuncBody_Str_Colon_3 */
/* cc900-name: SLDst_DrawPanelMemItemRows=SingleLoadDst_DrawPanelMemItemRows */
void SLDst_DrawPanelMemItemRows(long obj, unsigned char n)
{
	char *p;
	char *d;
	char *s;
	char **t;

	p = SINGLE_LOAD_DST_ROWS;
	p[42] = 2;
	p[63] = 3;
	t = StorageArea_UnitNames;
	s = t[SINGLE_LOAD_AREA];
	d = p + 43;
	s++;
	if (SINGLE_LOAD_ALL != 0) {
		FileIO_CopyString(d, s);
		FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 43, SlDst_Str_Colon_2);
		TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_DST_ROWS + 43, 16);
		FileIO_CopyString(SINGLE_LOAD_DST_ROWS + 64, Str_AllOption_EA09B2);
	} else {
		FileIO_CopyString(d, s);
		FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 43, SlDst_Str_Colon_3);
		FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 43,
		                     NumToAscii_FormatNumber((unsigned char)(SLOAD_DST_PMEM_POS % n + 1), 0));
		TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_DST_ROWS + 43, 16);
		SingleLoad_GetFileMemoryName(SINGLE_LOAD_DST_ROWS + 63, SLOAD_DST_PMEM_POS, 3);
	}
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 42));
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 63));
}
