/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/file_demo_proc_m0.c (2026-11-19-73-p6-r53)
   sha256 dc5816ad20028328ed58689828a6b39289e4b3c2de5fb032eb049cf9a17ad67f (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_CheckRegionSignature(int r);
extern void FileIO_CloseHandle(void);
extern void FileIO_ReadBlock(void *, long);
extern void PreMidiLoad(void);
extern void PostMidiLoad(int);
extern void *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void *__cdecl Memset(void *, int, unsigned int);
extern void FlashWrite(int, unsigned char *, unsigned int, long);
extern char FileIO_LoadRegion7_Flash_Str_rb[];
int FileIO_LoadRegion7_Flash(char *src)
{
	char hd[14];
	unsigned char *buf;
	int r;

	FileIO_ReadHeader(hd, src, 7);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion7_Flash_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(7) != 0) {
		PreMidiLoad();
		if ((buf = (unsigned char *)Malloc(0x400)) != 0) {
			Memset(buf, 0x400, 0);
			FileIO_ReadBlock(buf, 0x400);
			FlashWrite(1, buf, 0x400, 0x3d3000);
			Free(buf);
			r = FileIO_ReturnError();
		} else
			r = -200;
		PostMidiLoad(r);
	} else
		r = -102;
	FileIO_CloseHandle();
	return r;
}
