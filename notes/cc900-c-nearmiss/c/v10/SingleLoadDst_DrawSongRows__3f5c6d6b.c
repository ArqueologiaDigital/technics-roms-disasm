/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_2m269a.c (2026-11-19-15-p6-r42)
   sha256 3f5c6d6beed5f44dba20420e6d9e57bfcd51bf1b2166d51378cc81e194939613 (tar-sha256); compiled at -O3 -XS -Xr */
#define EVT_PARA_DRAW      0x1c0000fL
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern char *BuildSlotLabel(unsigned int, unsigned int, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_DST_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SLOAD_DST_SONG;
extern char *StorageArea_UnitNames[];
extern char SLDstMemLabel_ColonSep[];
void SingleLoadDst_DrawSongRows(long obj)
{
	char *p;

	p = SINGLE_LOAD_DST_ROWS;
	p[21] = 1;
	FileIO_CopyString(p + 22, StorageArea_UnitNames[SINGLE_LOAD_AREA] + 1);
	FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 22, SLDstMemLabel_ColonSep);
	FileIO_BuildFilePath(SINGLE_LOAD_DST_ROWS + 22, NumToAscii_FormatNumber((unsigned char)(SLOAD_DST_SONG + 1), 0));
	TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_DST_ROWS + 22, 16);
	FileIO_CopyString(SINGLE_LOAD_DST_ROWS + 42, BuildSlotLabel(SLOAD_DST_SONG, 2, 0));
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 21));
	ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_DST_ROWS + 42));
}
