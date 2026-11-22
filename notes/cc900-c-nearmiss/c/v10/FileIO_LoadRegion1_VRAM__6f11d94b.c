/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_20r1m266c.c (2026-11-21-2-p6-r58)
   sha256 6f11d94bc0fc8abe40ef3df248372dc986acfb400c0383f42501a81cbb72a29d (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_CheckRegionSignature(int r);
extern void FileIO_ReadBlock(void *, long);
extern void FileIO_SeekAndReadBlock(long, int);
extern void FileIO_CloseHandle(void);
extern int FileIO_ReadHeaderAtF(void);
extern void PanelMemory_PreBankLoad(int);
extern void PanelMemory_PostBankLoad(int, int);
extern void PrePmLoad(void);
extern void PostPmLoad(int);
extern char FileIO_LoadRegion1_VRAM_Str_rb[];
extern unsigned char ram_1ed350[];
extern unsigned char ram_200000[];
int FileIO_LoadRegion1_VRAM(char *src)
{
	char hd[14];
	int r;

	FileIO_ReadHeader(hd, src, 1);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion1_VRAM_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(1) != 0) {
		if (FileIO_ReadHeaderAtF() != 0) {
			PanelMemory_PreBankLoad(0);
			FileIO_SeekAndReadBlock(0x10, 0);
			FileIO_ReadBlock((unsigned char *)((long)ram_1ed350 + 0x10), 0x10);
			FileIO_SeekAndReadBlock(0xb0, 0);
			FileIO_ReadBlock((unsigned char *)((long)ram_1ed350 + 0xb0),
				(unsigned long)*(unsigned int *)((long)ram_1ed350 + 13) << 3);
			r = FileIO_ReturnError();
			PanelMemory_PostBankLoad(0, r);
		} else {
			PrePmLoad();
			FileIO_ReadBlock(ram_1ed350, (long)ram_200000 - (long)ram_1ed350);
			r = FileIO_ReturnError();
			PostPmLoad(r);
		}
	} else
		r = -102;
	FileIO_CloseHandle();
	return r;
}
