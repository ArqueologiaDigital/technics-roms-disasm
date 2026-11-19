/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/smf_operations_m269.c (2026-11-19-15-p6-r42)
   sha256 f5ffff4dfbe39b7e7a034e4dd8ab9c357ee2586c47be862d61d3871b2439248a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeqFromSong_Str_FROM_SONG=SeqFromSong_BuildEntry_Str_FROM_SONG */
#define EVT_PAINT               0x1c0000bL
#define EVT_PARA_DRAW           0x1c0000fL
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near ram_8060[];
extern long __near ram_805c;
extern unsigned char __near ram_8890;
extern char SeqFromSong_Str_FROM_SONG[];
long SmfSeqFromSongNumFunc(long obj, long evt, long par)
{
	char *p;

	switch (evt) {
	case EVT_PS_FILE_NAME_BOX_ID:
		ram_805c = par;
		break;
	case EVT_PAINT:
		p = ram_8060;
		*p = 0;
		FileIO_CopyString(p + 1, SeqFromSong_Str_FROM_SONG);
		FileIO_BuildFilePath(ram_8060 + 1, NumToAscii_FormatNumber((unsigned char)(ram_8890 + 1), 2));
		ApPostEvent(ram_805c, EVT_PARA_DRAW, 0x8118L);
		break;
	}
	return 0;
}
