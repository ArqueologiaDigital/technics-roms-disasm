/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_10m266d.c (2026-11-19-83-p6-r56)
   sha256 e93a2a759794c98c55cb1d8c6af920cc5b50d57bed26421b8dcb3481d32b6caf (tar-sha256); compiled at -O3 -Xr */
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
int FileIO_LoadRegion2_ExtMem(char *src)
{
	char hd[14];
	int r;
	long n;

	FileIO_ReadHeader(hd, src, 2);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion2_ExtMem_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(2) != 0) {
		if (FileIO_ReadHeaderAt4() != 0) {
			SeqLoadPre();
			FileIO_ReadBlock(SEQ_SONG_SLOTS, 0x5000);
			n = ram_fd800 - ram_b0000;
		FileIO_ReadBlock(ram_b0000, n);
			r = FileIO_ReturnError();
			SeqLoadPost(r);
		} else {
			SeqLoad_JumpInitFromPreset();
			FileIO_ReadBlock(SEQ_SONG_SLOTS, 0x800);
			n = ram_fd800 - ram_b0000;
		FileIO_ReadBlock(ram_b0000, n);
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
