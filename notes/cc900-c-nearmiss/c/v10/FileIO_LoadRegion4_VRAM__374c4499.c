/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_9m266a.c (2026-11-19-75-p6-r54)
   sha256 374c44998fdc9185ee6eb971af81e004760deb9889fc4734114a246e0292e044 (tar-sha256); compiled at -O3 -Xr */
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_CheckRegionSignature(int r);
extern void FileIO_ReadBlock(void *, long);
extern void FileIO_CloseHandle(void);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
extern void PreTmLoad(void);
extern void PostTmLoad(int);
extern int PostTmSave_ByteBlock(unsigned char *);
extern void PostTmSave_Success(int);
extern char FileIO_LoadRegion4_VRAM_Str_rb[];
extern unsigned char ram_1e0000[];
extern unsigned char ram_1e7800[];
int FileIO_LoadRegion4_VRAM(char *src)
{
	char hd[14];
	unsigned char b[16];
	int r;
	int i;
	int c;
	unsigned char *p;

	FileIO_ReadHeader(hd, src, 4);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion4_VRAM_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(4) != 0) {
		PreTmLoad();
		FileIO_ReadBlock(p = ram_1e0000, ram_1e7800 - p);
		r = FileIO_ReturnError();
		PostTmLoad(r);
	} else {
		for (i = 0; i < 16; i++) {
			if ((c = FileIO_ReadByte()) < 0)
				break;
			b[i] = c;
		}
		r = FileIO_ReturnError();
		if (r >= 0) {
			r = PostTmSave_ByteBlock(b);
			if (r >= 0) {
				FileIO_SeekRead_ExtReturn();
				FileIO_ReadBlock(p = ram_1e0000, ram_1e7800 - p);
				r = FileIO_ReturnError();
			}
		}
		PostTmSave_Success(r);
	}
	FileIO_CloseHandle();
	return r;
}
