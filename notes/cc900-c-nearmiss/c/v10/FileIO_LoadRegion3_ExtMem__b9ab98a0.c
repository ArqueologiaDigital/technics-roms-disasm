/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_8m266c.c (2026-11-19-68-p6-r52)
   sha256 b9ab98a09670c009688461873e6d24c067a936ebd9136854eb987f815b6c998b (tar-sha256); compiled at -O3 -Xr */
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_CheckRegionSignature(int r);
extern void FileIO_ReadBlock(void *, long);
extern void FileIO_CloseHandle(void);
extern void cmp_ld_mae(void);
extern void cmp_ld_ato(int);
extern int ToneParam_ExtendedOpsBlock(void);
extern char FileIO_LoadRegion3_ExtMem_Str_rb[];
extern unsigned char SEQ_SONG_SLOTS[];
extern unsigned char RHYTHM_PATTERN_BUF_A[];
int FileIO_LoadRegion3_ExtMem(char *src)
{
	char hd[14];
	int r;

	FileIO_ReadHeader(hd, src, 3);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion3_ExtMem_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(3) != 0) {
		cmp_ld_mae();
		FileIO_ReadBlock(RHYTHM_PATTERN_BUF_A, SEQ_SONG_SLOTS - RHYTHM_PATTERN_BUF_A);
		r = FileIO_ReturnError();
		cmp_ld_ato(r);
	} else
		r = ToneParam_ExtendedOpsBlock();
	FileIO_CloseHandle();
	return r;
}
