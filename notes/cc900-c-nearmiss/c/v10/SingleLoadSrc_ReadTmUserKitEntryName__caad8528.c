/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_27r1m268b.c (2026-11-22-7-p6-r74)
   sha256 caad8528c1ca8db061f40e06f001db629f54dfe5d1a7fc7aa2e73351a2bfc772 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: GFEBI_Entry2_Str_rb=GetFileEntryByIndex_Entry2_Str_rb
   cc900-name: SLSrc_ReadTmUserKitEntryName=SingleLoadSrc_ReadTmUserKitEntryName */
extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern void FileIO_SeekAndReadBlock(long, int);
extern void FileIO_ReadBlock(void *, long);
extern void FileIO_CloseHandle(void);
extern char FileIO_EmptyEntryName[];
extern char GFEBI_Entry2_Str_rb[];
extern char ram_25c56[];
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
	if (FileIO_OpenWithMode(hd, GFEBI_Entry2_Str_rb) < 0)
		goto empty;
	ram_25c56[0] = ' ';
	FileIO_SeekAndReadBlock(e * 80 + 0x4aa7, 0);
	FileIO_ReadBlock(ram_25c56 + 1, 13);
	ram_25c56[14] = 0;
	FileIO_CloseHandle();
	return ram_25c56;
empty:
	return FileIO_EmptyEntryName;
}
