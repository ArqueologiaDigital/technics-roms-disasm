/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_9m266a.c (2026-11-19-75-p6-r54)
   sha256 374c44998fdc9185ee6eb971af81e004760deb9889fc4734114a246e0292e044 (tar-sha256); compiled at -Xr */
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
