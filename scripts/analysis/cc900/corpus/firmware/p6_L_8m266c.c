/* Phase 6, lane_p6 helper L, round 8, file c of module 266 -- NOT an alternative of 8m266a / b: new functions of
   demo/file_demo_proc.s, the FileIO_LoadRegionN family (dispatch-table targets, so in no call-target pool; no C
   defines them).  Each reads its region's 14-byte header name, opens it "rb" (failure: FileIO_ReturnError's
   result), checks the region signature (calr; 0 -> -102 in Region1 / 7), loads, closes and returns the result
   kept in IZ (XIZ in Region7, whose Malloc'd buffer lives there first).
   - Region0: live panel block 0xf980..0xffc0 and VRAM 0x1e7800..0x1e8000 between PreLswLoad / PostLswLoad,
     else FileData_AllocLoadAndParse.
   - Region1: with the header at F: panel memory banks (seek 0x10 / 0xb0, the second size from the word at +13,
     times 8), else the whole 0x1ed350..0x200000 between PrePmLoad / PostPmLoad.
   - Region7: a 0x400-byte buffer (Memset called with the ROM's argument order: buffer, 0x400, 0), read, flashed
     to 0x3d3000, freed; -200 when Malloc fails. */
/* cc900-module: FileIO_CheckRegionSignature FileIO_ReadHeaderAt4 FileIO_ReadHeaderAtF */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_CheckRegionSignature(int r);
extern void FileIO_ReadBlock(void *, long);
extern void FileIO_SeekAndReadBlock(long, int);
extern void FileIO_CloseHandle(void);
extern int FileIO_ReadHeaderAtF(void);
extern void PreLswLoad(void);
extern void PostLswLoad(int);
extern int FileData_AllocLoadAndParse(void);
extern void PanelMemory_PreBankLoad(int);
extern void PanelMemory_PostBankLoad(int, int);
extern void PrePmLoad(void);
extern void PostPmLoad(int);
extern void PreMidiLoad(void);
extern void PostMidiLoad(int);
extern void *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void *__cdecl Memset(void *, int, unsigned int);
extern void FlashWrite(int, unsigned char *, unsigned int, long);
extern char FileIO_LoadRegion0_VRAM_Str_rb[];
extern char FileIO_LoadRegion1_VRAM_Str_rb[];
extern char FileIO_LoadRegion7_Flash_Str_rb[];
extern unsigned char __near LIVE_PANEL_BLOCK[];
extern unsigned char __near ram_ffc0[];
extern unsigned char ram_1e7800[];
extern unsigned char ram_1e8000[];
extern unsigned char ram_1ed350[];
extern unsigned char ram_200000[];
extern int FileIO_LoadRegion0_VRAM(char *src);
extern int FileIO_LoadRegion1_VRAM(char *src);
extern int FileIO_LoadRegion7_Flash(char *src);

int FileIO_LoadRegion0_VRAM(char *src)
{
	char hd[14];
	int r;

	FileIO_ReadHeader(hd, src, 0);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion0_VRAM_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(0) != 0) {
		PreLswLoad();
		FileIO_ReadBlock(LIVE_PANEL_BLOCK, ram_ffc0 - LIVE_PANEL_BLOCK);
		FileIO_ReadBlock(ram_1e7800, ram_1e8000 - ram_1e7800);
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
			FileIO_ReadBlock(ram_1ed350 + 0x10, 0x10);
			FileIO_SeekAndReadBlock(0xb0, 0);
			FileIO_ReadBlock(ram_1ed350 + 0xb0, (unsigned long)*(unsigned int *)(ram_1ed350 + 13) << 3);
			r = FileIO_ReturnError();
			PanelMemory_PostBankLoad(0, r);
		} else {
			PrePmLoad();
			FileIO_ReadBlock(ram_1ed350, ram_200000 - ram_1ed350);
			r = FileIO_ReturnError();
			PostPmLoad(r);
		}
	} else
		r = -102;
	FileIO_CloseHandle();
	return r;
}

/* Regions 2, 3, 5, 6 (same shape; Region2 keeps its argument in the frame and, on success, runs
   VoiceSynth_CmdCase0 on it after closing). */
extern int FileIO_ReadHeaderAt4(void);
extern void SeqLoadPre(void);
extern void SeqLoadPost(int);
extern void SeqLoad_JumpInitFromPreset(void);
extern void SeqLoad_PostAltEntry(int);
extern void VoiceSynth_CmdCase0(char *);
extern void cmp_ld_mae(void);
extern void cmp_ld_ato(int);
extern int ToneParam_ExtendedOpsBlock(void);
extern void msp_ld_mae(void);
extern void msp_ld_ato(int);
extern int FileIO_LoadMspAltFormat(void);
extern int FileIO_LoadRcmToFlash(void);
extern char FileIO_LoadRegion2_ExtMem_Str_rb[];
extern char FileIO_LoadRegion3_ExtMem_Str_rb[];
extern char FileIO_LoadRegion5_VRAM_Str_rb[];
extern char FileIO_LoadRegion6_Simple_Str_rb[];
extern unsigned char SEQ_SONG_SLOTS[];
extern unsigned char RHYTHM_PATTERN_BUF_A[];
extern unsigned char ram_b0000[];
extern unsigned char ram_fd800[];
extern unsigned char ram_1e8800[];
extern unsigned char ram_1ec400[];
extern int FileIO_LoadRegion2_ExtMem(char *src);
extern int FileIO_LoadRegion3_ExtMem(char *src);
extern int FileIO_LoadRegion5_VRAM(char *src);
extern int FileIO_LoadRegion6_Simple(char *src);

int FileIO_LoadRegion2_ExtMem(char *src)
{
	char hd[14];
	int r;

	FileIO_ReadHeader(hd, src, 2);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion2_ExtMem_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(2) != 0) {
		if (FileIO_ReadHeaderAt4() != 0) {
			SeqLoadPre();
			FileIO_ReadBlock(SEQ_SONG_SLOTS, 0x5000);
			FileIO_ReadBlock(ram_b0000, ram_fd800 - ram_b0000);
			r = FileIO_ReturnError();
			SeqLoadPost(r);
		} else {
			SeqLoad_JumpInitFromPreset();
			FileIO_ReadBlock(SEQ_SONG_SLOTS, 0x800);
			FileIO_ReadBlock(ram_b0000, ram_fd800 - ram_b0000);
			r = FileIO_ReturnError();
			SeqLoad_PostAltEntry(r);
		}
	} else
		r = -102;
	FileIO_CloseHandle();
	if (r >= 0)
		VoiceSynth_CmdCase0(src);
	return r;
}

int FileIO_LoadRegion3_ExtMem(char *src)
{
	char hd[14];
	int r;

	FileIO_ReadHeader(hd, src, 3);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion3_ExtMem_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(3) != 0) {
		cmp_ld_mae();
		FileIO_ReadBlock(RHYTHM_PATTERN_BUF_A, SEQ_SONG_SLOTS - RHYTHM_PATTERN_BUF_A);
		r = FileIO_ReturnError();
		cmp_ld_ato(r);
	} else
		r = ToneParam_ExtendedOpsBlock();
	FileIO_CloseHandle();
	return r;
}

int FileIO_LoadRegion5_VRAM(char *src)
{
	char hd[14];
	int r;

	FileIO_ReadHeader(hd, src, 5);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion5_VRAM_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(5) != 0) {
		msp_ld_mae();
		FileIO_ReadBlock(ram_1e8800, ram_1ec400 - ram_1e8800);
		r = FileIO_ReturnError();
		msp_ld_ato(r);
	} else
		r = FileIO_LoadMspAltFormat();
	FileIO_CloseHandle();
	return r;
}

int FileIO_LoadRegion6_Simple(char *src)
{
	char hd[14];
	int r;

	FileIO_ReadHeader(hd, src, 6);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion6_Simple_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(6) != 0)
		r = FileIO_LoadRcmToFlash();
	else
		r = -102;
	FileIO_CloseHandle();
	return r;
}

int FileIO_LoadRegion7_Flash(char *src)
{
	char hd[14];
	unsigned char *buf;
	int r;

	FileIO_ReadHeader(hd, src, 7);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion7_Flash_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(7) != 0) {
		PreMidiLoad();
		if ((buf = (unsigned char *)Malloc(0x400)) != 0) {
			Memset(buf, 0x400, 0);
			FileIO_ReadBlock(buf, 0x400);
			FlashWrite(1, buf, 0x400, 0x3d3000);
			Free(buf);
			r = FileIO_ReturnError();
		} else
			r = -200;
		PostMidiLoad(r);
	} else
		r = -102;
	FileIO_CloseHandle();
	return r;
}
