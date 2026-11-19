/* Phase 6, lane_p6 helper L, round 9, file c of module 266 (demo/file_demo_proc.s) -- NOT an alternative of
   9m266a / b: retries of ReadDualFile and LoadFileMultiPass.
   - LoadFileMultiPass (r52 O3Xr +25 / real spot +55): the ROM indexes FileIO_TypeProbeOrder with `lda xwa,tbl;
     (xwa+iz)` where V4.23 widened an unsigned counter (extz, add): the counter is a plain int (as in ReadDualFile,
     whose same loop matched that part).
   - ReadDualFile (r52 +1, the result spilled to the frame): locals declared as in LoadFileMultiPass (index, result,
     counter), whose result V4.23 did keep in QIZ. */
/* (no module-local callee) */

extern char FileIO_TypeProbeOrder[];
extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern char FileIO_CheckRecordValid(char);
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_CopyAndOpen(char *, char *);
extern char MultiPass_LoopNext_Str_wb[];
extern int FileIO_OpenDefault(char *);
extern void *FileIO_GetRecordByType(int);
extern int FileIO_ReturnError(void);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int SeqSave_PreparePartData(int);
extern void FileIO_CloseHandle(void);
extern int ReadDualFile(char *name);
extern int LoadFileMultiPass(unsigned int part);

int ReadDualFile(char *name)
{
	char n2[10];
	char n1[10];
	char h2[14];
	char h1[14];
	int idx;
	int r;
	int i;

	r = 0;
	idx = GetCurrentFileIndex();
	if (idx < 0)
		return -104;
	FileIO_FormatFileIndex(n1, (unsigned char)idx, GetFileEntryPtr(idx));
	FileIO_FormatFileIndex(n2, (unsigned char)idx, name);
	for (i = 0; i < 10; i++)
		if (FileIO_CheckRecordValid(FileIO_TypeProbeOrder[i]) != 0) {
			FileIO_ReadHeader(h1, n1, FileIO_TypeProbeOrder[i]);
			FileIO_ReadHeader(h2, n2, FileIO_TypeProbeOrder[i]);
			r = FileIO_CopyAndOpen(h1, h2);
			if (r < 0)
				break;
		}
	return r;
}

int LoadFileMultiPass(unsigned int part)
{
	char nm[10];
	char hd[14];
	int idx;
	int r;
	int i;

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
