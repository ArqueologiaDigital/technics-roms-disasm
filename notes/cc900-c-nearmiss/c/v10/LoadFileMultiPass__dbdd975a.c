/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_8m266a.c (2026-11-19-68-p6-r52)
   sha256 dbdd975a2b6bb7a2f89a34c5143abafa95e0f10f41d8731abe59c462b48de3d8 (tar-sha256); compiled at -O3 -Xr */
extern char FileIO_TypeProbeOrder[];
extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern char FileIO_CheckRecordValid(char);
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern char MultiPass_LoopNext_Str_wb[];
extern int FileIO_OpenDefault(char *);
extern void *FileIO_GetRecordByType(int);
extern int FileIO_ReturnError(void);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int SeqSave_PreparePartData(int);
extern void FileIO_CloseHandle(void);
int LoadFileMultiPass(unsigned int part)
{
	char nm[10];
	char hd[14];
	int idx;
	int r;
	unsigned int i;

	idx = GetCurrentFileIndex();
	if (idx < 0)
		return -104;
	i = (unsigned char)idx;
	FileIO_FormatFileIndex(nm, i, GetFileEntryPtr(idx));
	for (i = 0; i < 10; i++)
		if (FileIO_CheckRecordValid(FileIO_TypeProbeOrder[i]) != 0) {
			FileIO_ReadHeader(hd, nm, FileIO_TypeProbeOrder[i]);
			if ((r = FileIO_OpenDefault(hd)) < 0)
				return r;
		}
	i = (unsigned char)idx;
	FileIO_FormatFileIndex(nm, i, FileIO_GetRecordByType(idx));
	FileIO_ReadHeader(hd, nm, 2);
	if (FileIO_OpenWithMode(hd, MultiPass_LoopNext_Str_wb) < 0)
		return FileIO_ReturnError();
	r = SeqSave_PreparePartData((unsigned char)part);
	FileIO_CloseHandle();
	if (r < 0)
		FileIO_OpenDefault(hd);
	return r;
}
