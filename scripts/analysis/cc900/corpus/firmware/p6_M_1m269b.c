/* Phase 6, lane_p6 helper M, round 1, module 269, form b (alternative to p6_M_1m269a.c).
   SingleLoadSrc_DrawSoundMemBankRows: the bank-row limit as an unsigned char local (the ROM adds n to itself in A
   and compares bytes). */
/* cc900-name: SlSrcEntry_Str_Colon_4=SLSrcBankList_FuncBody_Entry_Str_Colon_4 */
/* cc900-name: SLSrc_DrawSoundMemBankRows=SingleLoadSrc_DrawSoundMemBankRows */
/* cc900-module: SingleLoad_GetSoundMemBankName TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PARA_DRAW           0x1c0000fL

extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern void SingleLoad_GetSoundMemBankName(char *, unsigned int, unsigned int);
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SLOAD_SRC_SOUND_POS;
extern char *SingleLoad_BankCaptionByMode[];
extern char SlSrcEntry_Str_Colon_4[];
extern void SLSrc_DrawSoundMemBankRows(long obj, unsigned char n);

void SLSrc_DrawSoundMemBankRows(long obj, unsigned char n)
{
	char *p;
	unsigned char lim;
	unsigned char pos;

	p = SINGLE_LOAD_SRC_ROWS;
	*p = 0;
	FileIO_CopyString(p + 1, SingleLoad_BankCaptionByMode[SINGLE_LOAD_AREA] + 1);
	FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 1, SlSrcEntry_Str_Colon_4);
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 1, 16);
	ApPostEvent(obj, EVT_PARA_DRAW, 0x894eL);
	lim = n + n;
	pos = SLOAD_SRC_SOUND_POS;
	if (pos < lim) {
		SingleLoad_GetSoundMemBankName(SINGLE_LOAD_SRC_ROWS + 21, pos / n, 1);
		ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 21));
	}
}
