/* lane_p6 helper J, round 27r1, form c: module 268 (demo/file_demo_proc.s), the SINGLE LOAD source-list name
   readers: SingleLoadSrc_ReadSqtSongName / ReadPmtBankName (family 4 of families27_J) and their five look-alikes
   in the same stretch, ReadPmtMemoryName, ReadCmpPatternName, ReadTmSoundName, ReadTmUserKitName,
   ReadTmUserKitEntryName (pool singletons of the same shape).  Each: the selected file index (GetCurrentFileIndex),
   its 8.3 name (FileIO_FormatFileIndex into buf, FileIO_ReadHeader into hd), open 'rb', seek, read N bytes into
   a RAM buffer, NUL-terminate, close, return the buffer; FileIO_EmptyEntryName when no file or the open fails.
   Frame: hd +0, buf +14 (address-taken, buf declared first), the spilled argument above them; the byte index
   (unsigned char)i homed in IZ.
   Form c: the open test wraps the success path (`if (open >= 0) { ... return buf; }`), the index test
   `goto empty;` to the final `return FileIO_EmptyEntryName;`.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FileIO_FormatFileIndex FileIO_ReadHeader GetCurrentFileIndex GetFileEntryPtr */   /* scripts/analysis/cc900/module_calls.py v10 */
/* cc900-name: SLSrc_ReadCmpPatternName=SingleLoadSrc_ReadCmpPatternName */
/* cc900-name: SLSrc_ReadTmUserKitEntryName=SingleLoadSrc_ReadTmUserKitEntryName */
/* cc900-name: FileIO_DP2_Str_rb=FileIO_ByteBlock_DemoProc2_Str_rb */
/* cc900-name: FileIO_DP2_Str_rb_2=FileIO_ByteBlock_DemoProc2_Str_rb_2 */
/* cc900-name: FileIO_DP2_Str_rb_3=FileIO_ByteBlock_DemoProc2_Str_rb_3 */
/* cc900-name: FileIO_DP2_Str_rb_4=FileIO_ByteBlock_DemoProc2_Str_rb_4 */
/* cc900-name: GFEBI_Entry_Str_rb=GetFileEntryByIndex_Entry_Str_rb */
/* cc900-name: GFEBI_Entry2_Str_rb=GetFileEntryByIndex_Entry2_Str_rb */

extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern void FileIO_SeekAndReadBlock(long, int);
extern void FileIO_ReadBlock(void *, long);
extern int FileIO_ReadByte(void);
extern void FileIO_CloseHandle(void);
extern char FileIO_EmptyEntryName[];
extern char FileIO_DP2_Str_rb[];
extern char FileIO_DP2_Str_rb_2[];
extern char FileIO_DP2_Str_rb_3[];
extern char FileIO_DP2_Str_rb_4[];
extern char FileOp_StubAndDirNames[];
extern char GFEBI_Entry_Str_rb[];
extern char GFEBI_Entry2_Str_rb[];
extern char ram_25bd2[];
extern char ram_25be8[];
extern char ram_25bfe[];
extern char ram_25c14[];
extern char ram_25c2a[];
extern char ram_25c40[];
extern char ram_25c56[];

char *SingleLoadSrc_ReadPmtBankName(unsigned int bank)
{
	char buf[10];
	char hd[14];
	int i;
	unsigned int n;

	i = GetCurrentFileIndex();
	if (i < 0)
		goto empty;
	n = (unsigned char)i;
	FileIO_FormatFileIndex(buf, n, GetFileEntryPtr(i));
	FileIO_ReadHeader(hd, buf, 1);
	if (FileIO_OpenWithMode(hd, FileOp_StubAndDirNames) >= 0) {
		FileIO_SeekAndReadBlock(bank * 16 + 16, 0);
		FileIO_ReadBlock(ram_25bd2, 16);
		ram_25bd2[16] = 0;
		FileIO_CloseHandle();
		return ram_25bd2;
	}
empty:
	return FileIO_EmptyEntryName;
}

char *SingleLoadSrc_ReadPmtMemoryName(unsigned int mem)
{
	char buf[10];
	char hd[14];
	int i;
	unsigned int n;

	i = GetCurrentFileIndex();
	if (i < 0)
		goto empty;
	n = (unsigned char)i;
	FileIO_FormatFileIndex(buf, n, GetFileEntryPtr(i));
	FileIO_ReadHeader(hd, buf, 1);
	if (FileIO_OpenWithMode(hd, FileIO_DP2_Str_rb) >= 0) {
		FileIO_SeekAndReadBlock(13, 0);
		n = FileIO_ReadByte();
		n |= FileIO_ReadByte() << 8;
		FileIO_SeekAndReadBlock((unsigned long)n * mem + 178, 0);
		FileIO_ReadBlock(ram_25be8, 16);
		ram_25be8[16] = 0;
		FileIO_CloseHandle();
		return ram_25be8;
	}
empty:
	return FileIO_EmptyEntryName;
}

char *SingleLoadSrc_ReadSqtSongName(unsigned int song)
{
	char buf[10];
	char hd[14];
	int i;
	unsigned int n;

	i = GetCurrentFileIndex();
	if (i < 0)
		goto empty;
	n = (unsigned char)i;
	FileIO_FormatFileIndex(buf, n, GetFileEntryPtr(i));
	FileIO_ReadHeader(hd, buf, 2);
	if (FileIO_OpenWithMode(hd, FileIO_DP2_Str_rb_2) >= 0) {
		FileIO_SeekAndReadBlock(song * 0x800 + 256, 0);
		FileIO_ReadBlock(ram_25bfe, 16);
		ram_25bfe[16] = 0;
		FileIO_CloseHandle();
		return ram_25bfe;
	}
empty:
	return FileIO_EmptyEntryName;
}

char *SLSrc_ReadCmpPatternName(unsigned int bank, unsigned int slot)
{
	char buf[10];
	char hd[14];
	int i;
	unsigned int n;

	i = GetCurrentFileIndex();
	if (i < 0)
		goto empty;
	n = (unsigned char)i;
	FileIO_FormatFileIndex(buf, n, GetFileEntryPtr(i));
	FileIO_ReadHeader(hd, buf, 3);
	if (FileIO_OpenWithMode(hd, FileIO_DP2_Str_rb_3) >= 0) {
		FileIO_SeekAndReadBlock((bank * 4 + slot) * 96 + 160, 0);
		FileIO_ReadBlock(ram_25c14, 13);
		ram_25c14[13] = 0;
		FileIO_CloseHandle();
		return ram_25c14;
	}
empty:
	return FileIO_EmptyEntryName;
}

char *SingleLoadSrc_ReadTmSoundName(unsigned int snd)
{
	char buf[10];
	char hd[14];
	int i;
	unsigned int n;

	i = GetCurrentFileIndex();
	if (i < 0)
		goto empty;
	n = (unsigned char)i;
	FileIO_FormatFileIndex(buf, n, GetFileEntryPtr(i));
	FileIO_ReadHeader(hd, buf, 4);
	if (FileIO_OpenWithMode(hd, FileIO_DP2_Str_rb_4) >= 0) {
		FileIO_SeekAndReadBlock(snd * 470 + 16, 0);
		FileIO_ReadBlock(ram_25c2a, 16);
		ram_25c2a[16] = 0;
		FileIO_CloseHandle();
		return ram_25c2a;
	}
empty:
	return FileIO_EmptyEntryName;
}

char *SingleLoadSrc_ReadTmUserKitName(void)
{
	char buf[10];
	char hd[14];
	int i;
	unsigned int n;

	i = GetCurrentFileIndex();
	if (i < 0)
		goto empty;
	n = (unsigned char)i;
	FileIO_FormatFileIndex(buf, n, GetFileEntryPtr(i));
	FileIO_ReadHeader(hd, buf, 4);
	if (FileIO_OpenWithMode(hd, GFEBI_Entry_Str_rb) >= 0) {
		FileIO_SeekAndReadBlock(0x4980, 0);
		FileIO_ReadBlock(ram_25c40, 16);
		ram_25c40[16] = 0;
		FileIO_CloseHandle();
		return ram_25c40;
	}
empty:
	return FileIO_EmptyEntryName;
}

char *SLSrc_ReadTmUserKitEntryName(unsigned int e)
{
	char buf[10];
	char hd[14];
	int i;
	unsigned int n;

	i = GetCurrentFileIndex();
	if (i < 0)
		goto empty;
	n = (unsigned char)i;
	FileIO_FormatFileIndex(buf, n, GetFileEntryPtr(i));
	FileIO_ReadHeader(hd, buf, 4);
	if (FileIO_OpenWithMode(hd, GFEBI_Entry2_Str_rb) >= 0) {
		ram_25c56[0] = ' ';
		FileIO_SeekAndReadBlock(e * 80 + 0x4aa7, 0);
		FileIO_ReadBlock(ram_25c56 + 1, 13);
		ram_25c56[14] = 0;
		FileIO_CloseHandle();
		return ram_25c56;
	}
empty:
	return FileIO_EmptyEntryName;
}
