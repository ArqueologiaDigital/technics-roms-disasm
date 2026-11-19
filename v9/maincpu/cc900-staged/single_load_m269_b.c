/* Functions of file_io/single_load.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: NumToAscii_FormatNumber SingleLoad_GetComposerBankName SingleLoad_GetSoundMemBankName TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern void SLSrcBankList_FuncBody(long obj, unsigned char n);
extern void SingleLoad_GetComposerBankName(char *, unsigned int, unsigned int);
extern char __near SINGLE_LOAD_DST_ROWS[];
extern unsigned char __near SLOAD_DST_CMP_POS;
extern char SlDst_Str_Colon_5[];
extern void SLDst_DrawComposerBankRows(long obj, unsigned char n);
extern void SingleLoad_GetSoundMemBankName(char *, unsigned int, unsigned int);
extern unsigned char __near SLOAD_SRC_SOUND_POS;
extern char SlSrcEntry_Str_Colon_4[];
extern void SLSrc_DrawSoundMemBankRows(long obj, unsigned char n);

/* cc900-name: SlSrc_Str_Colon=SLSrcBankList_FuncBody_Str_Colon */
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

/* cc900-name: SLDst_DrawComposerBankRows=SingleLoadDst_DrawComposerBankRows */
/* cc900-name: SlDst_Str_Colon_5=SLDstBankList_FuncBody_Str_Colon_5 */
void SLDst_DrawComposerBankRows(long obj, unsigned char n)
{
	char *p;

	p = SINGLE_LOAD_DST_ROWS;
	*p = 0;
	FileIO_CopyString(p + 1, SingleLoad_BankCaptionByMode[SINGLE_LOAD_AREA] + 1);
	FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 1, SlDst_Str_Colon_5);
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_DST_ROWS + 1, 16);
	SingleLoad_GetComposerBankName(SINGLE_LOAD_DST_ROWS + 21, SLOAD_DST_CMP_POS / n, 1);
	ApPostEvent(obj, EVT_PARA_DRAW, 0x89a2L);
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 21));
}

/* cc900-name: SLSrc_DrawSoundMemBankRows=SingleLoadSrc_DrawSoundMemBankRows */
/* cc900-name: SlSrcEntry_Str_Colon_4=SLSrcBankList_FuncBody_Entry_Str_Colon_4 */
void SLSrc_DrawSoundMemBankRows(long obj, unsigned char n)
{
	char *p;

	p = SINGLE_LOAD_SRC_ROWS;
	*p = 0;
	FileIO_CopyString(p + 1, SingleLoad_BankCaptionByMode[SINGLE_LOAD_AREA] + 1);
	FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 1, SlSrcEntry_Str_Colon_4);
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 1, 16);
	ApPostEvent(obj, EVT_PARA_DRAW, 0x894eL);
	if (SLOAD_SRC_SOUND_POS < (unsigned char)(n + n)) {
		SingleLoad_GetSoundMemBankName(SINGLE_LOAD_SRC_ROWS + 21, SLOAD_SRC_SOUND_POS / n, 1);
		ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 21));
	}
}
