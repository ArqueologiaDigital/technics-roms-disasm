/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/smf_operations_m269.c (2026-11-18-33-p6-r37)
   sha256 2625a8f14681dba54ce9c8c32eff1f9c7056588052896745f5775ca07cf905a5 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeqToSong_Str_TO_SONG=SeqToSong_BuildEntry_Str_TO_SONG */
#define EVT_PAINT               0x1c0000bL
#define EVT_PARA_DRAW           0x1c0000fL
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern char *NumToAscii_FormatNumber(unsigned int, unsigned int);
extern long ApPostEvent(long, long, long);
extern char __near ram_7fdc[];
extern long __near ram_7fd8;
extern unsigned char __near ram_8890;
extern char SeqToSong_Str_TO_SONG[];
long SmfSeqToSongNumFunc(long obj, long evt, long par)
{
	char *p;

	switch (evt) {
	case EVT_PS_FILE_NAME_BOX_ID:
		ram_7fd8 = par;
		break;
	case EVT_PAINT:
		p = ram_7fdc;
		*p = 0;
		FileIO_CopyString(p + 1, SeqToSong_Str_TO_SONG);
		FileIO_BuildFilePath(ram_7fdc + 1, NumToAscii_FormatNumber((unsigned char)(ram_8890 + 1), 2));
		ApPostEvent(ram_7fd8, EVT_PARA_DRAW, 0x8094L);
		break;
	}
	return 0;
}
