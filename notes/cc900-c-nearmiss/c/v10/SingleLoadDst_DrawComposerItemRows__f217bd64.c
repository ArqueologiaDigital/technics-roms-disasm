/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/single_load_m269.c (2026-11-22-12-p6-r79)
   sha256 f217bd64f5578e3fed894f148e3ff0a37bdc2f175f224370b7f44de3a0c994de (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: SLDst_DrawComposerItemRows=SingleLoadDst_DrawComposerItemRows
   cc900-name: SL_GetComposerSectionName=SingleLoad_GetComposerSectionName
   cc900-name: SlDst_Str_Colon_2=SLDstBankList_FuncBody_Str_Colon_2
   cc900-name: SlDst_Str_Colon_3=SLDstBankList_FuncBody_Str_Colon_3
   cc900-name: SlDst_Str_Colon_6=SLDstBankList_FuncBody_Str_Colon_6 */
#define EVT_PARA_DRAW      0x1c0000fL
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_DST_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near SLOAD_DST_CMP_POS;
extern char *StorageArea_UnitNames[];
extern char SlDst_Str_Colon_2[], SlDst_Str_Colon_3[], SlDst_Str_Colon_6[], SLDstBankList_FuncBody_Str_ALL[];
extern char *SingleLoad_GetVariationName(unsigned int);
extern void SL_GetComposerSectionName(char *, unsigned int, unsigned int, int);
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
