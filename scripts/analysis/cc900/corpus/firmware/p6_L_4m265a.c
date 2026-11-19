/* Phase 6, lane_p6 helper L, round 4, form a: module 265 (demo/file_demo_proc.s), new.
   - FDemo_LinkedListLookupField: the data pointer of the named entry (struct fent as the matched
     cc900/file_demo_proc_m265.c has it), 0 when absent.
   - FDemo_FileOpenAndProcess (second routine of that pool row): copy the name to a 16-byte buffer; when it is not
     already listed, open it "rb", read its whole size into a new buffer and register it; returns the open result.
     Locals declared r, data, buf (plain scalars lowest, the buffer above). */
/* cc900-module: FDemo_AllocBuffer FDemo_LinkedListSearch FDemo_LinkedListSearchInsert FDemo_RegisterLoadedFile */   /* scripts/analysis/cc900/module_calls.py v10 */

struct fent { char name[16]; void *data; char pad[4]; };
extern struct fent *FDemo_LinkedListSearch(char *name);
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
extern void *FDemo_LinkedListLookupField(char *name);
extern int FDemo_FileOpenAndProcess(char *name);

void *FDemo_LinkedListLookupField(char *name)
{
	struct fent *e;

	e = FDemo_LinkedListSearch(name);
	if (e != 0)
		return e->data;
	return 0;
}

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
