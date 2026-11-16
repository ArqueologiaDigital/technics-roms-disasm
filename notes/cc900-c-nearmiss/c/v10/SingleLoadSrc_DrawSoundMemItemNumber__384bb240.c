/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_15m269.c (2026-11-16-107-p6-r21)
   sha256 384bb24087c9395746593716b26ba35b6d6bf875dabf61fc85c2bb0475b6717b (tar-sha256); compiled at -O3 -Xr
   cc900-name: SlSrcEntry_Str_Colon_5=SLSrcBankList_FuncBody_Entry_Str_Colon_5 */
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near SLOAD_SRC_SOUND_POS;
extern char *StorageArea_UnitNames[];
extern char SlSrcEntry_Str_Colon_5[], Str_AllOption_EA0980[];
void SingleLoadSrc_DrawSoundMemItemNumber(long obj, unsigned char n)
{
	char *p, *t;
	unsigned char e, c;

	p = SINGLE_LOAD_SRC_ROWS;
	p[42] = 2;
	FileIO_CopyString(p + 43, StorageArea_UnitNames[SINGLE_LOAD_AREA] + 1);
	FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 43, SlSrcEntry_Str_Colon_5);
	if (SINGLE_LOAD_ALL == 0) {
		e = n + n;
		c = SLOAD_SRC_SOUND_POS;
		t = SINGLE_LOAD_SRC_ROWS + 43;
		FileIO_BuildFilePath(t, c >= e ? NumToAscii_FormatNumber((unsigned char)(c - e + 1), 0)
		                               : NumToAscii_FormatNumber((unsigned char)(c % n + 1), 0));
	}
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 43, 16);
	ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_SRC_ROWS + 42));
	if (SINGLE_LOAD_ALL == 0) return;
	p = SINGLE_LOAD_SRC_ROWS;
	p[63] = 3;
	FileIO_CopyString(p + 64, Str_AllOption_EA0980);
	ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_SRC_ROWS + 63));
}
