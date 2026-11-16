/* Phase 6, lane_p6 helper D, round 13, form b (refining round 11 after run 92: the conditional number through a
   temporary, the row cleared and passed as p + 1, the first row posted by its address as a number, as the ROM's
   5-byte ld shows), module 269 (v10 file_io/single_load.s): single-load list painters (SingleLoadSrc_PanelMemDrawMemoryNumber
   matched in run 92 and is left out).
   Each writes a caption row into SINGLE_LOAD_SRC_ROWS / SINGLE_LOAD_DST_ROWS (unit name, colon, number), pads it with
   TrimAndPadSmfFilename and posts it with ApPostEvent; numbers come from NumToAscii_FormatNumber (both same module,
   calr).  EVT_PARA_DRAW is 0x1c0000f.  The colon strings' labels share their first 31 characters with siblings, so
   they are declared under short names. */
/* cc900-module: NumToAscii_FormatNumber SingleLoad_GetFileBankName TrimAndPadSmfFilename */   /* from scripts/analysis/cc900/module_calls.py v10 */

/* cc900-name: SlSrc_Str_Colon_2=SLSrcBankList_FuncBody_Str_Colon_2 */
/* cc900-name: SlSrcEntry_Str_Colon_5=SLSrcBankList_FuncBody_Entry_Str_Colon_5 */
/* cc900-name: SlDst_Str_Colon=SLDstBankList_FuncBody_Str_Colon */

extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern void SingleLoad_GetFileBankName(char *, unsigned int, unsigned int);
extern long ApPostEvent(long, long, long);

extern char __near SINGLE_LOAD_SRC_ROWS[];
extern char __near SINGLE_LOAD_DST_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near SLOAD_SRC_PMEM_POS;
extern unsigned char __near SLOAD_SRC_SOUND_POS;
extern unsigned char __near SLOAD_DST_PMEM_POS;
extern char *StorageArea_UnitNames[], *SingleLoad_BankCaptionByMode[];
extern char SlSrc_Str_Colon_2[], SlSrcEntry_Str_Colon_5[], SLSrcBankList_FuncBody_Str_ALL[], Str_AllOption_EA0980[];
extern char SlDst_Str_Colon[];

void SingleLoadSrc_DrawSoundMemItemNumber(long obj, unsigned char n)
{
	char *p;
	unsigned char e, c;
	char *s;

	p = SINGLE_LOAD_SRC_ROWS;
	p[42] = 2;
	FileIO_CopyString(p + 43, StorageArea_UnitNames[SINGLE_LOAD_AREA] + 1);
	FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 43, SlSrcEntry_Str_Colon_5);
	if (SINGLE_LOAD_ALL == 0) {
		e = n + n;
		c = SLOAD_SRC_SOUND_POS;
		if (c >= e) s = NumToAscii_FormatNumber((unsigned char)(c - e + 1), 0);
		else s = NumToAscii_FormatNumber((unsigned char)(c % n + 1), 0);
		FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 43, s);
	}
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 43, 16);
	ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_SRC_ROWS + 42));
	if (SINGLE_LOAD_ALL == 0) return;
	p = SINGLE_LOAD_SRC_ROWS;
	p[63] = 3;
	FileIO_CopyString(p + 64, Str_AllOption_EA0980);
	ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_SRC_ROWS + 63));
}

void SLDstBankList_FuncBody(long obj, unsigned char n)
{
	char *p;

	p = SINGLE_LOAD_DST_ROWS;
	*p = 0;
	FileIO_CopyString(p + 1,SingleLoad_BankCaptionByMode[SINGLE_LOAD_AREA] + 1);
	FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 1, SlDst_Str_Colon);
	FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 1, NumToAscii_FormatNumber((unsigned char)(SLOAD_DST_PMEM_POS / n + 1), 0));
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_DST_ROWS + 1, 16);
	SingleLoad_GetFileBankName(SINGLE_LOAD_DST_ROWS + 21, SLOAD_DST_PMEM_POS / n, 1);
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_DST_ROWS + 22, 16);
	ApPostEvent(obj, 0x1c0000fL, 0x89a2L);
	ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_DST_ROWS + 21));
}
