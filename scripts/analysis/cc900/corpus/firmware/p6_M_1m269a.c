/* Phase 6, lane_p6 helper M, round 1, module 269, form a.
   SmfSeqFromSongNumFunc (file_io/smf_operations.s): twin of the built SmfSeqToSongNumFunc (cells 0x8114 / 0x8118,
   the FROM SONG caption).
   SLSrcBankList_FuncBody, SingleLoadDst_DrawComposerBankRows, SingleLoadSrc_DrawSoundMemBankRows
   (file_io/single_load.s): siblings of the built SLDstBankList_FuncBody / SingleLoadSrc_ComposerDrawBankName.
   SoundMem: the bank-row test as an unsigned char compare (cast of n + n). */
/* cc900-name: SeqFromSong_Str_FROM_SONG=SeqFromSong_BuildEntry_Str_FROM_SONG */
/* cc900-name: SlSrc_Str_Colon=SLSrcBankList_FuncBody_Str_Colon */
/* cc900-name: SlDst_Str_Colon_5=SLDstBankList_FuncBody_Str_Colon_5 */
/* cc900-name: SlSrcEntry_Str_Colon_4=SLSrcBankList_FuncBody_Entry_Str_Colon_4 */
/* cc900-name: SLDst_DrawComposerBankRows=SingleLoadDst_DrawComposerBankRows */
/* cc900-name: SLSrc_DrawSoundMemBankRows=SingleLoadSrc_DrawSoundMemBankRows */
/* cc900-module: NumToAscii_FormatNumber SingleLoad_GetComposerBankName SingleLoad_GetSoundMemBankName TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PAINT               0x1c0000bL
#define EVT_PARA_DRAW           0x1c0000fL
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L

extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern void SingleLoad_GetComposerBankName(char *, unsigned int, unsigned int);
extern void SingleLoad_GetSoundMemBankName(char *, unsigned int, unsigned int);

extern char __near ram_8118[];
extern long __near ram_8114;
extern unsigned char __near ram_8948;
extern char SeqFromSong_Str_FROM_SONG[];
extern long SmfSeqFromSongNumFunc(long obj, long evt, long par);

long SmfSeqFromSongNumFunc(long obj, long evt, long par)
{
	char *p;

	switch (evt) {
	case EVT_PS_FILE_NAME_BOX_ID:
		ram_8114 = par;
		break;
	case EVT_PAINT:
		p = ram_8118;
		*p = 0;
		FileIO_CopyString(p + 1, SeqFromSong_Str_FROM_SONG);
		FileIO_BuildFilePath(ram_8118 + 1, NumToAscii_FormatNumber((unsigned char)(ram_8948 + 1), 2));
		ApPostEvent(ram_8114, EVT_PARA_DRAW, 0x8118L);
		break;
	}
	return 0;
}

extern char __near SINGLE_LOAD_SRC_ROWS[];
extern char __near SINGLE_LOAD_DST_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SLOAD_SRC_PMEM_POS;
extern unsigned char __near SLOAD_DST_CMP_POS;
extern unsigned char __near SLOAD_SRC_SOUND_POS;
extern char *SingleLoad_BankCaptionByMode[];
extern char SlSrc_Str_Colon[];
extern char SlDst_Str_Colon_5[];
extern char SlSrcEntry_Str_Colon_4[];
extern void SLSrcBankList_FuncBody(long obj, unsigned char n);
extern void SLDst_DrawComposerBankRows(long obj, unsigned char n);
extern void SLSrc_DrawSoundMemBankRows(long obj, unsigned char n);

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
