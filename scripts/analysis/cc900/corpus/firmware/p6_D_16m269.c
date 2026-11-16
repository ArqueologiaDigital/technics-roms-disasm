/* Phase 6, lane_p6 helper D, round 16, module 269 (v10 file_io/single_load.s), form a:
   SingleLoadSrc_DrawSoundMemItemNumber after run 107.  At -O3 -Xr round 15's form a (conditional argument, row
   address in a local) differed only in that local: V4.23 kept it in a frame slot where the ROM keeps it in XIZ and
   copies it there in each branch after the compare.  Here each branch names the row address itself (if / else, two
   calls), so -O3 hoists the common address and keeps it across the number call; form b (p6_D_16m269b.c) keeps the
   conditional argument and declares the local `register`.
   EVT_PARA_DRAW is 0x1c0000f; the colon string's label shares its first 31 characters with siblings. */
/* cc900-module: NumToAscii_FormatNumber TrimAndPadSmfFilename */   /* from scripts/analysis/cc900/module_calls.py v10 */

/* cc900-name: SlSrcEntry_Str_Colon_5=SLSrcBankList_FuncBody_Entry_Str_Colon_5 */

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
	char *p;
	unsigned char e, c;

	p = SINGLE_LOAD_SRC_ROWS;
	p[42] = 2;
	FileIO_CopyString(p + 43, StorageArea_UnitNames[SINGLE_LOAD_AREA] + 1);
	FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 43, SlSrcEntry_Str_Colon_5);
	if (SINGLE_LOAD_ALL == 0) {
		e = n + n;
		c = SLOAD_SRC_SOUND_POS;
		if (c >= e)
			FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 43, NumToAscii_FormatNumber((unsigned char)(c - e + 1), 0));
		else
			FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 43, NumToAscii_FormatNumber((unsigned char)(c % n + 1), 0));
	}
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 43, 16);
	ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_SRC_ROWS + 42));
	if (SINGLE_LOAD_ALL == 0) return;
	p = SINGLE_LOAD_SRC_ROWS;
	p[63] = 3;
	FileIO_CopyString(p + 64, Str_AllOption_EA0980);
	ApPostEvent(obj, 0x1c0000fL, (long)(SINGLE_LOAD_SRC_ROWS + 63));
}
