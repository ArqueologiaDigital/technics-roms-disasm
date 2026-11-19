/* Phase 6, lane_p6 helper L, round 5, form a: module 265.  Retry of FDemo_FileOpenAndProcess (r46 O3Xr: right up to
   +62, then V4.23 put the buffer in XIZ and the size in the frame; the ROM has the size in XIZ and the buffer in
   the frame).  Size declared before the buffer pointer (idiom 4, declaration order moves the XIZ choice). */
/* cc900-module: FDemo_AllocBuffer FDemo_LinkedListSearchInsert FDemo_RegisterLoadedFile */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern int FDemo_FileOpenAndProcess(char *name);

int FDemo_FileOpenAndProcess(char *name)
{
	int r;
	long n;
	void *data;
	char buf[16];

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
