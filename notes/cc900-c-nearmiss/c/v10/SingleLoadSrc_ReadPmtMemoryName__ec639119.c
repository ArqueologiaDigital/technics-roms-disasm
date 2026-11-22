/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_27r1m268a.c (2026-11-22-7-p6-r74)
   sha256 ec639119341ff81b636892bf813c63af2ea3e4ada01d92bebe04e59bc35bdf6a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: FileIO_DP2_Str_rb=FileIO_ByteBlock_DemoProc2_Str_rb */
extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern void FileIO_SeekAndReadBlock(long, int);
extern void FileIO_ReadBlock(void *, long);
extern int FileIO_ReadByte(void);
extern void FileIO_CloseHandle(void);
extern char FileIO_EmptyEntryName[];
extern char FileIO_DP2_Str_rb[];
extern char ram_25be8[];
char *SingleLoadSrc_ReadPmtMemoryName(unsigned int mem)
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
	FileIO_ReadHeader(hd, buf, 1);
	if (FileIO_OpenWithMode(hd, FileIO_DP2_Str_rb) < 0)
		return FileIO_EmptyEntryName;
	FileIO_SeekAndReadBlock(13, 0);
	n = FileIO_ReadByte();
	n |= FileIO_ReadByte() << 8;
	FileIO_SeekAndReadBlock((unsigned long)n * mem + 178, 0);
	FileIO_ReadBlock(ram_25be8, 16);
	ram_25be8[16] = 0;
	FileIO_CloseHandle();
	return ram_25be8;
}
