/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/file_demo_proc_m0.c (2026-11-19-92-p6-r57)
   sha256 6361079918e7507e25903cb9fc9a3b62f6c14926403d54318b2fc32364b6cc0b (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_CheckRegionSignature(int r);
extern void FileIO_ReadBlock(void *, long);
extern void FileIO_CloseHandle(void);
extern void msp_ld_mae(void);
extern void msp_ld_ato(int);
extern int FileIO_LoadMspAltFormat(void);
extern char FileIO_LoadRegion5_VRAM_Str_rb[];
extern unsigned char ram_1e8800[];
extern unsigned char ram_1ec400[];
int FileIO_LoadRegion5_VRAM(char *src)
{
	char hd[14];
	int r;

	FileIO_ReadHeader(hd, src, 5);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion5_VRAM_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(5) != 0) {
		msp_ld_mae();
		FileIO_ReadBlock(ram_1e8800, (long)ram_1ec400 - (long)ram_1e8800);
		r = FileIO_ReturnError();
		msp_ld_ato(r);
	} else
		r = FileIO_LoadMspAltFormat();
	FileIO_CloseHandle();
	return r;
}
