/* helper X, round 21r2: SingleLoadDst_DrawSoundMemItemRows (file_io/single_load.s, module 269), modelled on its
   promoted sibling SingleLoadDst_DrawSongRows (cc900/single_load_m269_c.c).  Rows 2 and 3 of the destination list
   for SOUND MEMORY: "ALL", a USER KIT entry (pos >= 2C) or a sound (pos mod C + 1).  Form h = form g with one spot
   changed: the unit-name table's address taken into a local at the top (form g: named in each branch). */
/* cc900-module: NumToAscii_FormatNumber SingleLoad_GetSoundRamName SingleLoad_GetUserKitEntryName TrimAndPadSmfFilename */

#define EVT_PARA_DRAW 0x1c0000fL
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SLOAD_DST_SOUND_POS;
extern char __near SINGLE_LOAD_DST_ROWS[];
extern char *StorageArea_UnitNames[];
extern char SLDstBankList_FuncBody_Str_Colon_7[];
extern char SLDstBankList_FuncBody_Str_Colon_8[];
extern char SLDstBankList_FuncBody_Str_ALL_2[];
extern char SingleLoadDst_DrawSoundMemItemRows_Str_Colon[];
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern void SingleLoad_GetUserKitEntryName(char *, unsigned int, unsigned int);
extern void SingleLoad_GetSoundRamName(char *, unsigned int, unsigned int);
extern long ApPostEvent(long, long, long);

void SingleLoadDst_DrawSoundMemItemRows(long obj, unsigned char n)
{
	char **u;
	char *p;

	u = StorageArea_UnitNames;
	if (SINGLE_LOAD_ALL != 0) {
		p = SINGLE_LOAD_DST_ROWS;
		p[42] = 2;
		FileIO_CopyString(p + 43, u[SINGLE_LOAD_AREA] + 1);
		FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 43, SLDstBankList_FuncBody_Str_Colon_7);
		TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_DST_ROWS + 43, 16);
		p = SINGLE_LOAD_DST_ROWS;
		p[63] = 3;
		FileIO_CopyString(p + 64, SLDstBankList_FuncBody_Str_ALL_2);
	} else {
		p = SINGLE_LOAD_DST_ROWS;
		p[42] = 2;
		if (SLOAD_DST_SOUND_POS >= (unsigned char)(n + n)) {
			FileIO_CopyString(p + 43, u[SINGLE_LOAD_AREA] + 1);
			FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 43, SLDstBankList_FuncBody_Str_Colon_8);
			FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 43,
				NumToAscii_FormatNumber((unsigned char)(SLOAD_DST_SOUND_POS - (unsigned char)(n + n) + 1), 0));
			TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_DST_ROWS + 43, 16);
			SingleLoad_GetUserKitEntryName(SINGLE_LOAD_DST_ROWS + 63,
				(unsigned char)(SLOAD_DST_SOUND_POS - (unsigned char)(n + n)), 3);
		} else {
			FileIO_CopyString(p + 43, u[SINGLE_LOAD_AREA] + 1);
			FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 43, SingleLoadDst_DrawSoundMemItemRows_Str_Colon);
			FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 43,
				NumToAscii_FormatNumber((unsigned char)(SLOAD_DST_SOUND_POS % n + 1), 0));
			TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_DST_ROWS + 43, 16);
			SingleLoad_GetSoundRamName(SINGLE_LOAD_DST_ROWS + 63, SLOAD_DST_SOUND_POS, 3);
		}
	}
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 42));
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 63));
}
