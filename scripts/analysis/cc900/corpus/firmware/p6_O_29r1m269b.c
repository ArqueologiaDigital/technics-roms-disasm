/* lane_p6 helper O, round 29r1, form b: module 269 (file_io/single_load.s), SingleLoadDst_DrawPanelMemItemRows
   (206 B, singletons29_O).  Form a's if / else on the ALL flag, but the unit-name copy's two arguments are locals
   assigned before the flag test (the ROM has them in XWA / XBC before `cp (SINGLE_LOAD_ALL), 0`), and both branches
   call FileIO_CopyString with those locals.
   cc900-options: -O3 -Xr
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

	p = SINGLE_LOAD_DST_ROWS;
	p[42] = 2;
	p[63] = 3;
	s = StorageArea_UnitNames[SINGLE_LOAD_AREA] + 1;
	d = p + 43;
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
