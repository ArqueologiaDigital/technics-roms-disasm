/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/smf_operations_m269.c (2026-11-19-15-p6-r42)
   sha256 fa80d75a3f2c75e17738f1524f61a9c27d9cc187778851af5513c3979d876aba (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeqFromSong_Str_FROM_SONG=SeqFromSong_BuildEntry_Str_FROM_SONG */
#define EVT_PAINT               0x1c0000bL
#define EVT_PARA_DRAW           0x1c0000fL
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near ram_807c[];
extern long __near ram_8078;
extern unsigned char __near ram_88ac;
extern char SeqFromSong_Str_FROM_SONG[];
long SmfSeqFromSongNumFunc(long obj, long evt, long par)
{
	char *p;

	switch (evt) {
	case EVT_PS_FILE_NAME_BOX_ID:
		ram_8078 = par;
		break;
	case EVT_PAINT:
		p = ram_807c;
		*p = 0;
		FileIO_CopyString(p + 1, SeqFromSong_Str_FROM_SONG);
		FileIO_BuildFilePath(ram_807c + 1, NumToAscii_FormatNumber((unsigned char)(ram_88ac + 1), 2));
		ApPostEvent(ram_8078, EVT_PARA_DRAW, 0x8118L);
		break;
	}
	return 0;
}
