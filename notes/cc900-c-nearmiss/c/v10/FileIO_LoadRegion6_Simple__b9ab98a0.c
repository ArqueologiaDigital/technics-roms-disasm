/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_8m266c.c (2026-11-19-68-p6-r52)
   sha256 b9ab98a09670c009688461873e6d24c067a936ebd9136854eb987f815b6c998b (tar-sha256); compiled at -Xr */
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_CheckRegionSignature(int r);
extern void FileIO_CloseHandle(void);
extern int FileIO_LoadRcmToFlash(void);
extern char FileIO_LoadRegion6_Simple_Str_rb[];
int FileIO_LoadRegion6_Simple(char *src)
{
	char hd[14];
	int r;

	FileIO_ReadHeader(hd, src, 6);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion6_Simple_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(6) != 0)
		r = FileIO_LoadRcmToFlash();
	else
		r = -102;
	FileIO_CloseHandle();
	return r;
}
