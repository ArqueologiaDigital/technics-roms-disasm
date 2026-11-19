/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_10m266c.c (2026-11-19-83-p6-r56)
   sha256 2f7314d1ba003a2fccfe9b879aa52e6aeec07e1d1053119df37b6d7d53de31e6 (tar-sha256); compiled at -Xr */
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
		FileIO_ReadBlock(RHYTHM_PATTERN_BUF_A, (long)SEQ_SONG_SLOTS - (long)RHYTHM_PATTERN_BUF_A);
		r = FileIO_ReturnError();
		cmp_ld_ato(r);
	} else
		r = ToneParam_ExtendedOpsBlock();
	FileIO_CloseHandle();
	return r;
}
