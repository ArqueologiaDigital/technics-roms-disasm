/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_9m266b.c (2026-11-19-75-p6-r54)
   sha256 4488269f6ccd8d51b9cf4b519644d554c3397cf2483236ad2c0000d095068517 (tar-sha256); compiled at -O3 -Xr */
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_CheckRegionSignature(int r);
extern void FileIO_ReadBlock(void *, long);
extern void FileIO_CloseHandle(void);
extern void PreLswLoad(void);
extern void PostLswLoad(int);
extern int FileData_AllocLoadAndParse(void);
extern char FileIO_LoadRegion0_VRAM_Str_rb[];
extern unsigned char __near LIVE_PANEL_BLOCK[];
extern unsigned char __near ram_ffc0[];
extern unsigned char ram_1e7800[];
extern unsigned char ram_1e8000[];
int FileIO_LoadRegion0_VRAM(char *src)
{
	char hd[14];
	int r;
	unsigned char *p;

	FileIO_ReadHeader(hd, src, 0);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion0_VRAM_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(0) != 0) {
		PreLswLoad();
		p = LIVE_PANEL_BLOCK;
		FileIO_ReadBlock(p, ram_ffc0 - p);
		p = ram_1e7800;
		FileIO_ReadBlock(p, ram_1e8000 - p);
		r = FileIO_ReturnError();
		PostLswLoad(r);
	} else
		r = FileData_AllocLoadAndParse();
	FileIO_CloseHandle();
	return r;
}
