/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/smf_operations_m269.c (2026-11-18-33-p6-r37)
   sha256 0f8062b2dc932b2b60b2f90d137aacc70d91b72634a05c97f2e1770b5ce86d20 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeqToSong_Str_TO_SONG=SeqToSong_BuildEntry_Str_TO_SONG */
#define EVT_PAINT               0x1c0000bL
#define EVT_PARA_DRAW           0x1c0000fL
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near ram_7ff8[];
extern long __near ram_7ff4;
extern unsigned char __near ram_88ac;
extern char SeqToSong_Str_TO_SONG[];
long SmfSeqToSongNumFunc(long obj, long evt, long par)
{
	char *p;

	switch (evt) {
	case EVT_PS_FILE_NAME_BOX_ID:
		ram_7ff4 = par;
		break;
	case EVT_PAINT:
		p = ram_7ff8;
		*p = 0;
		FileIO_CopyString(p + 1, SeqToSong_Str_TO_SONG);
		FileIO_BuildFilePath(ram_7ff8 + 1, NumToAscii_FormatNumber((unsigned char)(ram_88ac + 1), 2));
		ApPostEvent(ram_7ff4, EVT_PARA_DRAW, 0x8094L);
		break;
	}
	return 0;
}
