/* Phase 6, lane_p6 helper S, round 1 of 2026-11-20, module 266 (demo/file_demo_proc.s), form a: one-spot retries
   of the three FileIO region functions still open after p6_L_10m266c.c (run r56 matched LoadRegion2-5 with
   `(long)E - (long)S`).
   - FileIO_LoadRegion0_VRAM (r56 +54): the far pair matches; the near pair (LIVE_PANEL_BLOCK .. ram_ffc0) differs
     in order only: the ROM loads S (the argument), then E, then copies S to XDE; V4.23 copied S before loading E.
     Form a computes the size into a long local first, `n = (long)E - (long)S; FileIO_ReadBlock(S, n);`.
   - FileIO_LoadRegion1_VRAM (r56: the inner body): the ROM does not fold `ram_1ed350 + 0x10`: lda of the base,
     then `add xwa,16`; for the second block it loads the base once, reads the count through it (+13) and adds
     0xb0 after the count: the base as an integer, `(long)ram_1ed350 + 0x10` (the idiom of the built
     MidiPkt_SetXferBlock_SoundRamData), the count through `(long)ram_1ed350 + 13`.
   - FileIO_SaveRegion0_VRAM (r56 +7): the ROM computes the near size first (into its frame slot) and the far one
     second (XIZ), and passes the two starts as integer constants (`ld xwa,0xf980`, `ld xwa,0x1e7800`, as the
     matched SaveRegion7's `(void *)0x3d3000L`): n1 first, `(long)` casts, constant arguments.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FileIO_CheckRegionSignature FileIO_ReadHeaderAtF */   /* p6_L_10m266c.c's line, these three's callees */

extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_OpenDefault(char *);
extern int FileIO_CheckRegionSignature(int r);
extern void FileIO_ReadBlock(void *, long);
extern void FileIO_SeekAndReadBlock(long, int);
extern void FileIO_CloseHandle(void);
extern int FileIO_ReadHeaderAtF(void);
extern long FileIO_GetDiskFreeSpace(void);
extern void FileIO_WriteByte_Impl(void *, long);
extern void PreLswLoad(void);
extern void PostLswLoad(int);
extern int FileData_AllocLoadAndParse(void);
extern void PanelMemory_PreBankLoad(int);
extern void PanelMemory_PostBankLoad(int, int);
extern void PrePmLoad(void);
extern void PostPmLoad(int);
extern void PreLswSave(void);
extern void PostLswSave(int);
extern char FileIO_LoadRegion0_VRAM_Str_rb[];
extern char FileIO_LoadRegion1_VRAM_Str_rb[];
extern char SaveRegion0_SpaceOk_Str_wb[];
extern unsigned char __near LIVE_PANEL_BLOCK[];
extern unsigned char __near ram_ffc0[];
extern unsigned char ram_1e7800[];
extern unsigned char ram_1e8000[];
extern unsigned char ram_1ed350[];
extern unsigned char ram_200000[];
extern int FileIO_LoadRegion0_VRAM(char *src);
extern int FileIO_LoadRegion1_VRAM(char *src);
extern int FileIO_SaveRegion0_VRAM(char *src);

int FileIO_LoadRegion0_VRAM(char *src)
{
	char hd[14];
	int r;
	long n;

	FileIO_ReadHeader(hd, src, 0);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion0_VRAM_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(0) != 0) {
		PreLswLoad();
		n = (long)ram_ffc0 - (long)LIVE_PANEL_BLOCK;
		FileIO_ReadBlock(LIVE_PANEL_BLOCK, n);
		FileIO_ReadBlock(ram_1e7800, (long)ram_1e8000 - (long)ram_1e7800);
		r = FileIO_ReturnError();
		PostLswLoad(r);
	} else
		r = FileData_AllocLoadAndParse();
	FileIO_CloseHandle();
	return r;
}

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

int FileIO_SaveRegion0_VRAM(char *src)
{
	long n1;
	char hd[14];
	long n2;
	int r;

	n1 = (long)ram_ffc0 - (long)LIVE_PANEL_BLOCK;
	n2 = (long)ram_1e8000 - (long)ram_1e7800;
	if (FileIO_GetDiskFreeSpace() < n1 + n2)
		return -101;
	FileIO_ReadHeader(hd, src, 0);
	if (FileIO_OpenWithMode(hd, SaveRegion0_SpaceOk_Str_wb) < 0)
		return FileIO_ReturnError();
	PreLswSave();
	FileIO_WriteByte_Impl((void *)0xf980L, n1);
	FileIO_WriteByte_Impl((void *)0x1e7800L, n2);
	r = FileIO_ReturnError();
	PostLswSave(r);
	FileIO_CloseHandle();
	if (r < 0)
		FileIO_OpenDefault(hd);
	return r;
}
