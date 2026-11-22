/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_27r1m268a.c (2026-11-22-7-p6-r74)
   sha256 ec639119341ff81b636892bf813c63af2ea3e4ada01d92bebe04e59bc35bdf6a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: FileIO_DP2_Str_rb_3=FileIO_ByteBlock_DemoProc2_Str_rb_3
   cc900-name: SLSrc_ReadCmpPatternName=SingleLoadSrc_ReadCmpPatternName */
extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern void FileIO_SeekAndReadBlock(long, int);
extern void FileIO_ReadBlock(void *, long);
extern void FileIO_CloseHandle(void);
extern char FileIO_EmptyEntryName[];
extern char FileIO_DP2_Str_rb_3[];
extern char ram_25c14[];
char *SLSrc_ReadCmpPatternName(unsigned int bank, unsigned int slot)
{
	char buf[10];
	char hd[14];
	int i;
	unsigned int n;

	i = GetCurrentFileIndex();
	if (i < 0)
		return FileIO_EmptyEntryName;
	n = (unsigned char)i;
	FileIO_FormatFileIndex(buf, n, GetFileEntryPtr(i));
	FileIO_ReadHeader(hd, buf, 3);
	if (FileIO_OpenWithMode(hd, FileIO_DP2_Str_rb_3) < 0)
		return FileIO_EmptyEntryName;
	FileIO_SeekAndReadBlock((bank * 4 + slot) * 96 + 160, 0);
	FileIO_ReadBlock(ram_25c14, 13);
	ram_25c14[13] = 0;
	FileIO_CloseHandle();
	return ram_25c14;
}
