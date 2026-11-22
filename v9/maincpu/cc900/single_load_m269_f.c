/* Functions of file_io/single_load.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SingleLoad_GetComposerSectionName SingleLoad_GetVariationName TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern void SLDst_DrawComposerItemRows(long obj, unsigned char n);

/* cc900-name: SLDst_DrawComposerItemRows=SingleLoadDst_DrawComposerItemRows */
/* cc900-name: SlDst_Str_Colon_2=SLDstBankList_FuncBody_Str_Colon_2 */
/* cc900-name: SlDst_Str_Colon_3=SLDstBankList_FuncBody_Str_Colon_3 */
/* cc900-name: SlDst_Str_Colon_6=SLDstBankList_FuncBody_Str_Colon_6 */
/* cc900-name: SL_GetComposerSectionName=SingleLoad_GetComposerSectionName */
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
