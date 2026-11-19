/* Phase 6, lane_p6 helper L, round 9, form a: module 266 (demo/file_demo_proc.s), the FileIO_LoadRegionN /
   SaveRegionN family.  r52: Region6 / 7 matched; 0 / 1 / 2 / 3 / 5 differ at the same spot: reading a start..end
   range, the ROM loads the start into XWA (the argument), the end into XBC, COPIES the start to XDE and subtracts
   XDE (round 8's `E - S` subtracted XWA directly).  The start goes through a pointer local p: `FileIO_ReadBlock(p = S, E - p)`.
   New: LoadRegion4 (a 16-byte read loop through FileIO_ReadByte, counter in IZ before the result) and SaveRegion7.
   SaveRegion0 (r52 +10): the ROM computes the first size in its frame slot and the second in XIZ: sizes declared
   second-first. */
/* cc900-module: FileIO_CheckRegionSignature FileIO_ReadHeaderAt4 FileIO_ReadHeaderAtF */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_OpenDefault(char *);
extern int FileIO_CheckRegionSignature(int r);
extern void FileIO_ReadBlock(void *, long);
extern void FileIO_SeekAndReadBlock(long, int);
extern void FileIO_CloseHandle(void);
extern int FileIO_ReadHeaderAtF(void);
extern int FileIO_ReadHeaderAt4(void);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
extern long FileIO_GetDiskFreeSpace(void);
extern void FileIO_WriteByte_Impl(void *, long);
extern void PreLswLoad(void);
extern void PostLswLoad(int);
extern int FileData_AllocLoadAndParse(void);
extern void PanelMemory_PreBankLoad(int);
extern void PanelMemory_PostBankLoad(int, int);
extern void PrePmLoad(void);
extern void PostPmLoad(int);
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
extern void PreTmLoad(void);
extern void PostTmLoad(int);
extern int PostTmSave_ByteBlock(unsigned char *);
extern void PostTmSave_Success(int);
extern void PreLswSave(void);
extern void PostLswSave(int);
extern void PreMidiSave(void);
extern void PostMidiSave(int);
extern char FileIO_LoadRegion0_VRAM_Str_rb[];
extern char FileIO_LoadRegion1_VRAM_Str_rb[];
extern char FileIO_LoadRegion2_ExtMem_Str_rb[];
extern char FileIO_LoadRegion3_ExtMem_Str_rb[];
extern char FileIO_LoadRegion4_VRAM_Str_rb[];
extern char FileIO_LoadRegion5_VRAM_Str_rb[];
extern char SaveRegion0_SpaceOk_Str_wb[];
extern char Resource_Region7_Start[];
extern unsigned char __near LIVE_PANEL_BLOCK[];
extern unsigned char __near ram_ffc0[];
extern unsigned char SEQ_SONG_SLOTS[];
extern unsigned char RHYTHM_PATTERN_BUF_A[];
extern unsigned char ram_b0000[];
extern unsigned char ram_fd800[];
extern unsigned char ram_1e0000[];
extern unsigned char ram_1e7800[];
extern unsigned char ram_1e8000[];
extern unsigned char ram_1e8800[];
extern unsigned char ram_1ec400[];
extern unsigned char ram_1ed350[];
extern unsigned char ram_200000[];
extern int FileIO_LoadRegion0_VRAM(char *src);
extern int FileIO_LoadRegion1_VRAM(char *src);
extern int FileIO_LoadRegion2_ExtMem(char *src);
extern int FileIO_LoadRegion3_ExtMem(char *src);
extern int FileIO_LoadRegion4_VRAM(char *src);
extern int FileIO_LoadRegion5_VRAM(char *src);
extern int FileIO_SaveRegion0_VRAM(char *src);
extern int FileIO_SaveRegion7_Flash(char *src);

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
		FileIO_ReadBlock(p = LIVE_PANEL_BLOCK, ram_ffc0 - p);
		FileIO_ReadBlock(p = ram_1e7800, ram_1e8000 - p);
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

int FileIO_LoadRegion2_ExtMem(char *src)
{
	char hd[14];
	int r;
	unsigned char *p;

	FileIO_ReadHeader(hd, src, 2);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion2_ExtMem_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(2) != 0) {
		if (FileIO_ReadHeaderAt4() != 0) {
			SeqLoadPre();
			FileIO_ReadBlock(SEQ_SONG_SLOTS, 0x5000);
			FileIO_ReadBlock(p = ram_b0000, ram_fd800 - p);
			r = FileIO_ReturnError();
			SeqLoadPost(r);
		} else {
			SeqLoad_JumpInitFromPreset();
			FileIO_ReadBlock(SEQ_SONG_SLOTS, 0x800);
			FileIO_ReadBlock(p = ram_b0000, ram_fd800 - p);
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
	unsigned char *p;

	FileIO_ReadHeader(hd, src, 3);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion3_ExtMem_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(3) != 0) {
		cmp_ld_mae();
		FileIO_ReadBlock(p = RHYTHM_PATTERN_BUF_A, SEQ_SONG_SLOTS - p);
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
	unsigned char *p;

	FileIO_ReadHeader(hd, src, 5);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion5_VRAM_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(5) != 0) {
		msp_ld_mae();
		FileIO_ReadBlock(p = ram_1e8800, ram_1ec400 - p);
		r = FileIO_ReturnError();
		msp_ld_ato(r);
	} else
		r = FileIO_LoadMspAltFormat();
	FileIO_CloseHandle();
	return r;
}

int FileIO_LoadRegion4_VRAM(char *src)
{
	char hd[14];
	unsigned char b[16];
	int r;
	int i;
	int c;
	unsigned char *p;

	FileIO_ReadHeader(hd, src, 4);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion4_VRAM_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(4) != 0) {
		PreTmLoad();
		FileIO_ReadBlock(p = ram_1e0000, ram_1e7800 - p);
		r = FileIO_ReturnError();
		PostTmLoad(r);
	} else {
		for (i = 0; i < 16; i++) {
			if ((c = FileIO_ReadByte()) < 0)
				break;
			b[i] = c;
		}
		r = FileIO_ReturnError();
		if (r >= 0) {
			r = PostTmSave_ByteBlock(b);
			if (r >= 0) {
				FileIO_SeekRead_ExtReturn();
				FileIO_ReadBlock(p = ram_1e0000, ram_1e7800 - p);
				r = FileIO_ReturnError();
			}
		}
		PostTmSave_Success(r);
	}
	FileIO_CloseHandle();
	return r;
}

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

int FileIO_SaveRegion7_Flash(char *src)
{
	char hd[14];
	int r;

	if (FileIO_GetDiskFreeSpace() < 0x400)
		return -101;
	FileIO_ReadHeader(hd, src, 7);
	if (FileIO_OpenWithMode(hd, Resource_Region7_Start) < 0)
		return FileIO_ReturnError();
	PreMidiSave();
	FileIO_WriteByte_Impl((void *)0x3d3000L, 0x400);
	r = FileIO_ReturnError();
	PostMidiSave(r);
	FileIO_CloseHandle();
	if (r < 0)
		FileIO_OpenDefault(hd);
	return r;
}
