/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FileIO_CheckRegionSignature FileIO_ReadHeaderAt4 FileIO_ReadHeaderAtF */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_CheckRegionSignature(int r);
extern void FileIO_ReadBlock(void *, long);
extern void FileIO_CloseHandle(void);
extern int FileIO_ReadHeaderAt4(void);
extern void SeqLoadPre(void);
extern void SeqLoadPost(int);
extern void SeqLoad_JumpInitFromPreset(void);
extern void SeqLoad_PostAltEntry(int);
extern void VoiceSynth_CmdCase0(char *);
extern char FileIO_LoadRegion2_ExtMem_Str_rb[];
extern unsigned char SEQ_SONG_SLOTS[];
extern unsigned char ram_b0000[];
extern unsigned char ram_fd800[];
extern int FileIO_LoadRegion2_ExtMem(char *src);
extern void cmp_ld_mae(void);
extern void cmp_ld_ato(int);
extern int ToneParam_ExtendedOpsBlock(void);
extern char FileIO_LoadRegion3_ExtMem_Str_rb[];
extern unsigned char RHYTHM_PATTERN_BUF_A[];
extern int FileIO_LoadRegion3_ExtMem(char *src);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
extern void PreTmLoad(void);
extern void PostTmLoad(int);
extern int PostTmSave_ByteBlock(unsigned char *);
extern void PostTmSave_Success(int);
extern char FileIO_LoadRegion4_VRAM_Str_rb[];
extern unsigned char ram_1e0000[];
extern unsigned char ram_1e7800[];
extern int FileIO_LoadRegion4_VRAM(char *src);
extern void msp_ld_mae(void);
extern void msp_ld_ato(int);
extern int FileIO_LoadMspAltFormat(void);
extern char FileIO_LoadRegion5_VRAM_Str_rb[];
extern unsigned char ram_1e8800[];
extern unsigned char ram_1ec400[];
extern int FileIO_LoadRegion5_VRAM(char *src);
extern int FileIO_OpenDefault(char *);
extern long FileIO_GetDiskFreeSpace(void);
extern void FileIO_WriteByte_Impl(void *, long);
extern void PreMidiSave(void);
extern void PostMidiSave(int);
extern char Resource_Region7_Start[];
extern int FileIO_SaveRegion7_Flash(char *src);

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
			FileIO_ReadBlock(ram_b0000, (long)ram_fd800 - (long)ram_b0000);
			r = FileIO_ReturnError();
			SeqLoadPost(r);
		} else {
			SeqLoad_JumpInitFromPreset();
			FileIO_ReadBlock(SEQ_SONG_SLOTS, 0x800);
			FileIO_ReadBlock(ram_b0000, (long)ram_fd800 - (long)ram_b0000);
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
		FileIO_ReadBlock(RHYTHM_PATTERN_BUF_A, (long)SEQ_SONG_SLOTS - (long)RHYTHM_PATTERN_BUF_A);
		r = FileIO_ReturnError();
		cmp_ld_ato(r);
	} else
		r = ToneParam_ExtendedOpsBlock();
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

	FileIO_ReadHeader(hd, src, 4);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion4_VRAM_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(4) != 0) {
		PreTmLoad();
		FileIO_ReadBlock(ram_1e0000, (long)ram_1e7800 - (long)ram_1e0000);
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
				FileIO_ReadBlock(ram_1e0000, (long)ram_1e7800 - (long)ram_1e0000);
				r = FileIO_ReturnError();
			}
		}
		PostTmSave_Success(r);
	}
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
		FileIO_ReadBlock(ram_1e8800, (long)ram_1ec400 - (long)ram_1e8800);
		r = FileIO_ReturnError();
		msp_ld_ato(r);
	} else
		r = FileIO_LoadMspAltFormat();
	FileIO_CloseHandle();
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
