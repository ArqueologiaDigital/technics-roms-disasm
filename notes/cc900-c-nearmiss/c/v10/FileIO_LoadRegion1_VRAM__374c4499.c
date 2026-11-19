/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_9m266a.c (2026-11-19-75-p6-r54)
   sha256 374c44998fdc9185ee6eb971af81e004760deb9889fc4734114a246e0292e044 (tar-sha256); compiled at -O3 -Xr */
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
	unsigned char *p;

	FileIO_ReadHeader(hd, src, 1);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion1_VRAM_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(1) != 0) {
		if (FileIO_ReadHeaderAtF() != 0) {
			PanelMemory_PreBankLoad(0);
			FileIO_SeekAndReadBlock(0x10, 0);
			FileIO_ReadBlock(ram_1ed350 + 0x10, 0x10);
			FileIO_SeekAndReadBlock(0xb0, 0);
			FileIO_ReadBlock(ram_1ed350 + 0xb0, (unsigned long)*(unsigned int *)(ram_1ed350 + 13) << 3);
			r = FileIO_ReturnError();
			PanelMemory_PostBankLoad(0, r);
		} else {
			PrePmLoad();
			FileIO_ReadBlock(p = ram_1ed350, ram_200000 - p);
			r = FileIO_ReturnError();
			PostPmLoad(r);
		}
	} else
		r = -102;
	FileIO_CloseHandle();
	return r;
}
