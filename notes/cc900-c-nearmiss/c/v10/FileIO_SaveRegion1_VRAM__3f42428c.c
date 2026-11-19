/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_8m266d.c (2026-11-19-68-p6-r52)
   sha256 3f42428c8d6c624b49a4af64fa7833b3465321952c46317a2ed84c5a49e09437 (tar-sha256); compiled at -O3 -Xr */
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
extern void PrePmSave(void);
extern void PostPmSave(int);
extern char SaveRegion1_SpaceOk_Str_wb[];
extern unsigned char ram_1ed350[];
extern unsigned char ram_200000[];
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
