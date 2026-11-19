/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/single_load_m269_b.c (2026-11-19-15-p6-r42)
   sha256 4c770ef945a189c7b3f0589e3d638e030a3116ae7070c6eeeb4a62ab16a4f896 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr
   cc900-name: SLDst_DrawComposerBankRows=SingleLoadDst_DrawComposerBankRows
   cc900-name: SlDst_Str_Colon_5=SLDstBankList_FuncBody_Str_Colon_5 */
#define EVT_PARA_DRAW           0x1c0000fL
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern unsigned char __near SINGLE_LOAD_AREA;
extern char *SingleLoad_BankCaptionByMode[];
extern void SingleLoad_GetComposerBankName(char *, unsigned int, unsigned int);
extern char __near SINGLE_LOAD_DST_ROWS[];
extern unsigned char __near SLOAD_DST_CMP_POS;
extern char SlDst_Str_Colon_5[];
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
