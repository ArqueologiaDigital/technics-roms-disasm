/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_4m265a.c (2026-11-19-29-p6-r46)
   sha256 0f5cfec86def8b7fff20176c7f9437fb84579d34d29eba33e82c2811ea8b1ade (tar-sha256); compiled at -O3 -Xr */
struct fent { char name[16]; void *data; char pad[4]; };
extern struct fent *FDemo_LinkedListSearchInsert(char *name);
extern char *__cdecl Strcpy(char *, char *);
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
	void *data;
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
