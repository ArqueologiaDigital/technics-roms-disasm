/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_27r1m268c.c (2026-11-22-7-p6-r74)
   sha256 bbe4d1bfef73f7e162dce651b0860d02274c9a56913e2375fda89d076adb6e43 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern void FileIO_SeekAndReadBlock(long, int);
extern void FileIO_ReadBlock(void *, long);
extern void FileIO_CloseHandle(void);
extern char FileIO_EmptyEntryName[];
extern char FileOp_StubAndDirNames[];
extern char ram_25bd2[];
char *SingleLoadSrc_ReadPmtBankName(unsigned int bank)
{
	char buf[10];
	char hd[14];
	int i;
	unsigned int n;

	i = GetCurrentFileIndex();
	if (i < 0)
		goto empty;
	n = (unsigned char)i;
	FileIO_FormatFileIndex(buf, n, GetFileEntryPtr(i));
	FileIO_ReadHeader(hd, buf, 1);
	if (FileIO_OpenWithMode(hd, FileOp_StubAndDirNames) >= 0) {
		FileIO_SeekAndReadBlock(bank * 16 + 16, 0);
		FileIO_ReadBlock(ram_25bd2, 16);
		ram_25bd2[16] = 0;
		FileIO_CloseHandle();
		return ram_25bd2;
	}
empty:
	return FileIO_EmptyEntryName;
}
