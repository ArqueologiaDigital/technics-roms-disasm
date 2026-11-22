/* lane_p6 helper O, round 29r1, form a: module 269 (file_io/single_load.s), the single-load destination item rows
   SingleLoadDst_DrawPanelMemItemRows (206 B) and SingleLoadDst_DrawComposerItemRows (198 B), singletons29_O; the
   twins of the built SLDstBankList_FuncBody / SingleLoadDst_DrawComposerBankRows / SLSrc_ComposerDrawPatternSlot
   (v10/maincpu/cc900/single_load_m269*.c), written the same way.
   Form a: PanelMem: if / else on the ALL flag with the unit-name copy written in both branches (the ROM computes its
   arguments before the flag compare and calls it in each branch); Composer: SLSrc_ComposerDrawPatternSlot's shape
   with the division and remainder spelled in the call.
   cc900-options: -O3 -Xr
*/
/* cc900-module: NumToAscii_FormatNumber SingleLoad_GetComposerSectionName SingleLoad_GetFileMemoryName SingleLoad_GetVariationName TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern unsigned char __near SLOAD_DST_CMP_POS;
extern char *StorageArea_UnitNames[];
extern char SlDst_Str_Colon_2[], SlDst_Str_Colon_3[], SlDst_Str_Colon_6[], SLDstBankList_FuncBody_Str_ALL[];
extern char Str_AllOption_EA09B2[];
extern void SingleLoad_GetFileMemoryName(char *, unsigned int, unsigned int);
extern char *SingleLoad_GetVariationName(unsigned int);
extern void SL_GetComposerSectionName(char *, unsigned int, unsigned int, int);
extern void SLDst_DrawPanelMemItemRows(long obj, unsigned char n);
extern void SLDst_DrawComposerItemRows(long obj, unsigned char n);

/* cc900-name: SlDst_Str_Colon_2=SLDstBankList_FuncBody_Str_Colon_2 */
/* cc900-name: SlDst_Str_Colon_3=SLDstBankList_FuncBody_Str_Colon_3 */
/* cc900-name: SlDst_Str_Colon_6=SLDstBankList_FuncBody_Str_Colon_6 */
/* cc900-name: SL_GetComposerSectionName=SingleLoad_GetComposerSectionName */
/* cc900-name: SLDst_DrawPanelMemItemRows=SingleLoadDst_DrawPanelMemItemRows */
/* cc900-name: SLDst_DrawComposerItemRows=SingleLoadDst_DrawComposerItemRows */
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

void SLDst_DrawComposerItemRows(long obj, unsigned char n)
{
	char *p;
	char *q;

	p = SINGLE_LOAD_DST_ROWS;
	p[42] = 2;
	FileIO_CopyString(p + 43, StorageArea_UnitNames[SINGLE_LOAD_AREA] + 1);
	FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 43, SlDst_Str_Colon_6);
	if (SINGLE_LOAD_ALL == 0)
		FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 43, SingleLoad_GetVariationName(SLOAD_DST_CMP_POS % n));
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_DST_ROWS + 43, 16);
	p = SINGLE_LOAD_DST_ROWS;
	q = p + 63;
	if (SINGLE_LOAD_ALL != 0) {
		*q = 3;
		FileIO_CopyString(p + 64, SLDstBankList_FuncBody_Str_ALL);
	} else
		SL_GetComposerSectionName(q, SLOAD_DST_CMP_POS / n, SLOAD_DST_CMP_POS % n, 3);
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 42));
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 63));
}
