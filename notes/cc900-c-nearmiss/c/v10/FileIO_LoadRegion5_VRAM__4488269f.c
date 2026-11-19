/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_9m266b.c (2026-11-19-75-p6-r54)
   sha256 4488269f6ccd8d51b9cf4b519644d554c3397cf2483236ad2c0000d095068517 (tar-sha256); compiled at -O3 -Xr */
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
	unsigned char *p;

	FileIO_ReadHeader(hd, src, 5);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion5_VRAM_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(5) != 0) {
		msp_ld_mae();
		p = ram_1e8800;
		FileIO_ReadBlock(p, ram_1ec400 - p);
		r = FileIO_ReturnError();
		msp_ld_ato(r);
	} else
		r = FileIO_LoadMspAltFormat();
	FileIO_CloseHandle();
	return r;
}
