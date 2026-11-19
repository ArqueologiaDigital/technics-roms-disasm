/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/file_demo_proc_m0.c (2026-11-19-92-p6-r57)
   sha256 6361079918e7507e25903cb9fc9a3b62f6c14926403d54318b2fc32364b6cc0b (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern void FileIO_CloseHandle(void);
extern int FileIO_OpenDefault(char *);
extern long FileIO_GetDiskFreeSpace(void);
extern void FileIO_WriteByte_Impl(void *, long);
extern void PreMidiSave(void);
extern void PostMidiSave(int);
extern char Resource_Region7_Start[];
int FileIO_SaveRegion7_Flash(char *src)
{
	char hd[14];
	int r;

	if (FileIO_GetDiskFreeSpace() < 0x400)
		return -101;
	FileIO_ReadHeader(hd, src, 7);
	if (FileIO_OpenWithMode(hd, Resource_Region7_Start) < 0)
		return FileIO_ReturnError();
	PreMidiSave();
	FileIO_WriteByte_Impl((void *)0x3d3000L, 0x400);
	r = FileIO_ReturnError();
	PostMidiSave(r);
	FileIO_CloseHandle();
	if (r < 0)
		FileIO_OpenDefault(hd);
	return r;
}
