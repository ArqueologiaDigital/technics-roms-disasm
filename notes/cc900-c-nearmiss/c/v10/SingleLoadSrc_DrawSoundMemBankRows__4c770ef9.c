/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/single_load_m269_b.c (2026-11-19-15-p6-r42)
   sha256 4c770ef945a189c7b3f0589e3d638e030a3116ae7070c6eeeb4a62ab16a4f896 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr
   cc900-name: SLSrc_DrawSoundMemBankRows=SingleLoadSrc_DrawSoundMemBankRows
   cc900-name: SlSrcEntry_Str_Colon_4=SLSrcBankList_FuncBody_Entry_Str_Colon_4 */
#define EVT_PARA_DRAW           0x1c0000fL
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern char *SingleLoad_BankCaptionByMode[];
extern void SingleLoad_GetSoundMemBankName(char *, unsigned int, unsigned int);
extern unsigned char __near SLOAD_SRC_SOUND_POS;
extern char SlSrcEntry_Str_Colon_4[];
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
