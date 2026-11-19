/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_6m265b.c (2026-11-19-49-p6-r49)
   sha256 56c50df2b4dc7a75cd5a528b31b54a2d19eed03604f8fab98e337dffaf2c83e0 (tar-sha256); compiled at -O3 -Xr */
extern char *__cdecl Strcpy(char *, char *);
extern void *FDemo_LinkedListSearchInsert(char *name);
extern char FDemo_FileOpen_DoOpen_Str_rb[];
extern int FileIO_OpenWithMode(char *name, char *mode);
extern void FileIO_SeekAndReadBlock(long, int);
extern long FileIO_SeekWriteBlock_Impl(void);
extern void FileIO_SeekRead_ExtReturn(void);
extern void *FDemo_AllocBuffer(long n);
extern void FileIO_ReadBlock(void *, long);
extern void FileIO_CloseHandle(void);
extern void FDemo_RegisterLoadedFile(char *name, void *data);
int FDemo_FileOpenAndProcess(char *name)
{
	int r;
	void *volatile data;
	char buf[16];
	long n;

	Strcpy(buf, name);
	if (FDemo_LinkedListSearchInsert(buf) != 0)
		return 0;
	r = FileIO_OpenWithMode(buf, FDemo_FileOpen_DoOpen_Str_rb);
	if (r >= 0) {
		FileIO_SeekAndReadBlock(0, 2);
		n = FileIO_SeekWriteBlock_Impl();
		FileIO_SeekRead_ExtReturn();
		data = FDemo_AllocBuffer(n);
		if (data != 0)
			FileIO_ReadBlock(data, n);
		FileIO_CloseHandle();
		FDemo_RegisterLoadedFile(buf, data);
	}
	return r;
}
