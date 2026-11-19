/* Phase 6, lane_p6 helper L, round 8, file d of module 266 (demo/file_demo_proc.s), new: FileIO_SaveRegion0 / 1,
   the save side of 8m266c's family.  Each checks the free disk space against the region sizes (-101 if short),
   names, opens "wb", writes, closes, and reopens the default file on a negative result.  The ROM keeps the
   (second) size in XIZ and then the result in IZ; the first size of Region0 in the frame below the header name.
   Region1 picks its size by FileIO_GetRecordAttr_Check: the bank part (word at +13 times 8, signed shift, plus
   0xb0) or the whole 0x1ed350..0x200000. */
/* (no module-local callee) */

extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_OpenDefault(char *);
extern void FileIO_CloseHandle(void);
extern long FileIO_GetDiskFreeSpace(void);
extern void FileIO_WriteByte_Impl(void *, long);
extern void FileIO_SeekAndReadBlock(long, int);
extern void FileIO_ReadByte_BufferHit(int);
extern char FileIO_GetRecordAttr_Check(void);
extern void PreLswSave(void);
extern void PostLswSave(int);
extern void PrePmSave(void);
extern void PostPmSave(int);
extern char SaveRegion0_SpaceOk_Str_wb[];
extern char SaveRegion1_SpaceOk_Str_wb[];
extern unsigned char __near LIVE_PANEL_BLOCK[];
extern unsigned char __near ram_ffc0[];
extern unsigned char ram_1e7800[];
extern unsigned char ram_1e8000[];
extern unsigned char ram_1ed350[];
extern unsigned char ram_200000[];
extern int FileIO_SaveRegion0_VRAM(char *src);
extern int FileIO_SaveRegion1_VRAM(char *src);

int FileIO_SaveRegion0_VRAM(char *src)
{
	long n1;
	char hd[14];
	long n2;
	int r;

	n1 = ram_ffc0 - LIVE_PANEL_BLOCK;
	n2 = ram_1e8000 - ram_1e7800;
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

int FileIO_SaveRegion1_VRAM(char *src)
{
	char hd[14];
	long n;
	int r;

	if (FileIO_GetRecordAttr_Check() != 0)
		n = (long)*(unsigned int *)(ram_1ed350 + 13) * 8 + 0xb0;
	else
		n = ram_200000 - ram_1ed350;
	if (FileIO_GetDiskFreeSpace() < n)
		return -101;
	FileIO_ReadHeader(hd, src, 1);
	if (FileIO_OpenWithMode(hd, SaveRegion1_SpaceOk_Str_wb) < 0)
		return FileIO_ReturnError();
	if (FileIO_GetRecordAttr_Check() != 0) {
		FileIO_WriteByte_Impl(ram_1ed350, n);
		FileIO_SeekAndReadBlock(0xf, 0);
		FileIO_ReadByte_BufferHit(8);
		r = FileIO_ReturnError();
	} else {
		PrePmSave();
		FileIO_WriteByte_Impl(ram_1ed350, n);
		r = FileIO_ReturnError();
		PostPmSave(r);
	}
	FileIO_CloseHandle();
	if (r < 0)
		FileIO_OpenDefault(hd);
	return r;
}
