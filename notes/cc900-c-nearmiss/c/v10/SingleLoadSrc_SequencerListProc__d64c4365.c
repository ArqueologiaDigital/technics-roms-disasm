/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_4m269a.c (2026-11-18-33-p6-r37)
   sha256 d64c4365a3d346024fb9f5f2e2700751068239e4ec21970bcafacff496096774 (tar-sha256); compiled at -O3 -Xr
   cc900-name: SlSrcEntry_Str_Colon=SLSrcBankList_FuncBody_Entry_Str_Colon */
#define EVT_PAINT          0x1c0000bL
#define EVT_PARA_DRAW      0x1c0000fL
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern char *StorageArea_UnitNames[];
extern char SlSrcEntry_Str_Colon[];
extern char *SingleLoadSrc_ReadSqtSongName(unsigned int);
long SingleLoadSrc_SequencerListProc(long obj, long evt, long par)
{
	char *p;
	char *q;

	if (evt == EVT_PAINT) {
		p = SINGLE_LOAD_SRC_ROWS;
		*p++ = 0;
		*p = 0;
		TrimAndPadSmfFilename((unsigned char *)p, 16);
		p = SINGLE_LOAD_SRC_ROWS;
		p[21] = 1;
		FileIO_CopyString(p + 22, StorageArea_UnitNames[SINGLE_LOAD_AREA] + 1);
		FileIO_BuildFilePath(SINGLE_LOAD_SRC_ROWS + 22, SlSrcEntry_Str_Colon);
		TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 22, 16);
		p = SINGLE_LOAD_SRC_ROWS;
		p[42] = 2;
		FileIO_CopyString(p + 43, SingleLoadSrc_ReadSqtSongName(0));
		TrimAndPadSmfFilename((unsigned char *)SINGLE_LOAD_SRC_ROWS + 43, 16);
		p = SINGLE_LOAD_SRC_ROWS;
		p[63] = 3;
		q = p + 64;
		*q = 0;
		TrimAndPadSmfFilename((unsigned char *)q, 16);
		ApPostEvent(obj, EVT_PARA_DRAW, 0x894eL);
		ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 21));
		ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 42));
		ApPostEvent(obj, EVT_PARA_DRAW, (long)(SINGLE_LOAD_SRC_ROWS + 63));
	}
	return 0;
}
