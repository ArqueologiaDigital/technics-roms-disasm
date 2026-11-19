/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_10m266c.c (2026-11-19-83-p6-r56)
   sha256 2f7314d1ba003a2fccfe9b879aa52e6aeec07e1d1053119df37b6d7d53de31e6 (tar-sha256); compiled at -Xr */
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
