/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_22m268b.c (2026-11-18-1-p6-r33)
   sha256 63e5a839f8fe2f458c622f084673c962cedcba248195c9d9531a82692a40e0a9 (tar-sha256); compiled at -O3 -Xr */
extern int FileIO_OpenWithMode(char *, char *);
extern int FileIO_SeekAndReadBlock(unsigned long, unsigned int);
extern void FileIO_ReadBlock(unsigned char *, unsigned long);
extern void FileIO_CloseHandle(void);
extern void TrimAndFormatFilename(unsigned int, unsigned char *, unsigned int);
extern unsigned char ram_25db6;
extern unsigned char ram_25d74[];
extern char DetectType_TryOpen_Str_MUSIC_DIR[], DetectType_TryOpen_Str_rb[];
extern char DetectType_TryExtended_Str_PIANODIR_FIL[], DetectType_TryExtended_Str_rb[];
int DetectFileType(void)
{
	unsigned char t;

	t = ram_25db6;
	if (t == 6 || t == 7) return t;
	if (t != 2) return -1;
	if (FileIO_OpenWithMode(DetectType_TryOpen_Str_MUSIC_DIR, DetectType_TryOpen_Str_rb) >= 0) {
		ram_25db6 = 6;
		FileIO_SeekAndReadBlock(0x10, 0);
		FileIO_ReadBlock(ram_25d74, 0x40);
		FileIO_SeekAndReadBlock(0x60, 0);
		FileIO_ReadBlock((unsigned char *)0x27200L, 0x3c);
		FileIO_CloseHandle();
		TrimAndFormatFilename(0x40, ram_25d74, 0);
		return ram_25db6;
	}
	if (FileIO_OpenWithMode(DetectType_TryExtended_Str_PIANODIR_FIL, DetectType_TryExtended_Str_rb) >= 0) {
		ram_25db6 = 7;
		FileIO_SeekAndReadBlock(0x12d8, 0);
		FileIO_ReadBlock(ram_25d74, 0x38);
		FileIO_CloseHandle();
		TrimAndFormatFilename(0x38, ram_25d74, 0);
		return ram_25db6;
	}
	return -1;
}
