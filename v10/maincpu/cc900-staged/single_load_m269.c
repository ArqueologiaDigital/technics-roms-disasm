/* Functions of file_io/single_load.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SingleLoad_GetComposerSectionName SingleLoad_GetVariationName TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near SLOAD_SRC_CMP_POS;
extern char *StorageArea_UnitNames[], *SingleLoad_BankCaptionByMode[];
extern char SlSrcEntry_Str_Colon_2[], SlSrcEntry_Str_Colon_3[], SlSrcEntry_Str_ALL[];
extern char *SingleLoad_GetVariationName(unsigned int);
extern void SL_GetComposerSectionName(char *, unsigned int, unsigned int, int);
extern void SLSrc_ComposerDrawPatternSlot(long obj, unsigned char n);

/* cc900-name: SLSrc_ComposerDrawPatternSlot=SingleLoadSrc_ComposerDrawPatternSlot */
/* cc900-name: SlSrcEntry_Str_Colon_2=SLSrcBankList_FuncBody_Entry_Str_Colon_2 */
/* cc900-name: SlSrcEntry_Str_Colon_3=SLSrcBankList_FuncBody_Entry_Str_Colon_3 */
/* cc900-name: SlSrcEntry_Str_ALL=SLSrcBankList_FuncBody_Entry_Str_ALL */
/* cc900-name: SL_GetComposerSectionName=SingleLoad_GetComposerSectionName */
void SLSrc_ComposerDrawPatternSlot(long obj, unsigned char n)
{
	unsigned int v;
	char *p;
	char *q;

	v = SLOAD_SRC_CMP_POS % n;
	p = SINGLE_LOAD_SRC_ROWS;
	p[42] = 2;
	FileIO_CopyString(p + 43, StorageArea_UnitNames[SINGLE_LOAD_AREA] + 1);
	FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 43, SlSrcEntry_Str_Colon_3);
	if (SINGLE_LOAD_ALL == 0)
		FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 43, SingleLoad_GetVariationName(v));
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 43, 16);
	ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_SRC_ROWS + 42));
	p = SINGLE_LOAD_SRC_ROWS;
	q = p + 63;
	if (SINGLE_LOAD_ALL != 0) {
		*q = 3;
		FileIO_CopyString(p + 64, SlSrcEntry_Str_ALL);
		ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_SRC_ROWS + 63));
	} else {
		if (v < 4)
			return;
		SL_GetComposerSectionName(q, SLOAD_SRC_CMP_POS / n, v, 3);
		ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_SRC_ROWS + 63));
	}
}
