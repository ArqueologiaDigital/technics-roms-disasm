/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_10m266d.c (2026-11-19-83-p6-r56)
   sha256 e93a2a759794c98c55cb1d8c6af920cc5b50d57bed26421b8dcb3481d32b6caf (tar-sha256); compiled at -Xr */
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_OpenDefault(char *);
extern void FileIO_CloseHandle(void);
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
