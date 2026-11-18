/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_1m269a.c (2026-11-18-12-p6-r35)
   sha256 ca398c0e95273c982a2ee0fef30d2dd4f5cd1ebf3978c018fc9c99f259654dcd (tar-sha256); compiled at -O3 -Xr
   cc900-name: SeqToSong_Str_TO_SONG=SeqToSong_BuildEntry_Str_TO_SONG */
#define EVT_PAINT               0x1c0000bL
#define EVT_PARA_DRAW           0x1c0000fL
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near ram_8094[];
extern long __near ram_8090;
extern unsigned char __near ram_8948;
extern char SeqToSong_Str_TO_SONG[];
long SmfSeqToSongNumFunc(long obj, long evt, long par)
{
	char *p;

	switch (evt) {
	case EVT_PS_FILE_NAME_BOX_ID:
		ram_8090 = par;
		break;
	case EVT_PAINT:
		p = ram_8094;
		*p = 0;
		FileIO_CopyString(p + 1, SeqToSong_Str_TO_SONG);
		FileIO_BuildFilePath(ram_8094 + 1, NumToAscii_FormatNumber((unsigned char)(ram_8948 + 1), 2));
		ApPostEvent(ram_8090, EVT_PARA_DRAW, (long)ram_8094);
		break;
	}
	return 0;
}
