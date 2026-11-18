/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_22m268.c (2026-11-18-1-p6-r33)
   sha256 d1729f01f9e6f80fd1060313c36ed5c67e53c27bfa5207ded865a250f744d548 (tar-sha256); compiled at -O3 -Xr */
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
	if (ram_25db6 == 6 || ram_25db6 == 7) return ram_25db6;
	if (ram_25db6 != 2) return -1;
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
