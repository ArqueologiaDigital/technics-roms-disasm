/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_8m266c.c (2026-11-19-68-p6-r52)
   sha256 b9ab98a09670c009688461873e6d24c067a936ebd9136854eb987f815b6c998b (tar-sha256); compiled at -Xr */
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_CheckRegionSignature(int r);
extern void FileIO_ReadBlock(void *, long);
extern void FileIO_CloseHandle(void);
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
