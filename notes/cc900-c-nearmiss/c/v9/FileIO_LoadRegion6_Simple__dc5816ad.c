/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/file_demo_proc_m0.c (2026-11-19-73-p6-r53)
   sha256 dc5816ad20028328ed58689828a6b39289e4b3c2de5fb032eb049cf9a17ad67f (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
