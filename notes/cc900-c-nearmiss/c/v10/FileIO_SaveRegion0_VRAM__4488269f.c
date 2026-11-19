/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_9m266b.c (2026-11-19-75-p6-r54)
   sha256 4488269f6ccd8d51b9cf4b519644d554c3397cf2483236ad2c0000d095068517 (tar-sha256); compiled at -O3 -Xr */
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_OpenDefault(char *);
extern void FileIO_CloseHandle(void);
extern long FileIO_GetDiskFreeSpace(void);
extern void FileIO_WriteByte_Impl(void *, long);
extern void PreLswSave(void);
extern void PostLswSave(int);
extern char SaveRegion0_SpaceOk_Str_wb[];
extern unsigned char __near LIVE_PANEL_BLOCK[];
extern unsigned char __near ram_ffc0[];
extern unsigned char ram_1e7800[];
extern unsigned char ram_1e8000[];
int FileIO_SaveRegion0_VRAM(char *src)
{
	long n1;
	char hd[14];
	long n2;
	int r;

	n2 = ram_1e8000 - ram_1e7800;
	n1 = ram_ffc0 - LIVE_PANEL_BLOCK;
	if (FileIO_GetDiskFreeSpace() < n1 + n2)
		return -101;
	FileIO_ReadHeader(hd, src, 0);
	if (FileIO_OpenWithMode(hd, SaveRegion0_SpaceOk_Str_wb) < 0)
		return FileIO_ReturnError();
	PreLswSave();
	FileIO_WriteByte_Impl(LIVE_PANEL_BLOCK, n1);
	FileIO_WriteByte_Impl(ram_1e7800, n2);
	r = FileIO_ReturnError();
	PostLswSave(r);
	FileIO_CloseHandle();
	if (r < 0)
		FileIO_OpenDefault(hd);
	return r;
}
