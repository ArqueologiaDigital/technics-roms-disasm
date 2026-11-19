/* Phase 6, lane_p6 helper L, round 8, form a: module 266 (demo/file_demo_proc.s), retries of r51's close misses.
   - LoadFileMultiPass (+6): the ROM stores the part parameter as a WORD and later widens its low byte, so the
     parameter is an unsigned int, cast to unsigned char at the call (K&R char stored only the byte).  O3Xr
     already matched the following bytes.
   - ReadDualFile (+1, frame): the ROM's frame is exactly the four buffers (52 B) with the result in QIZ and the
     index / loop counter in IZ; round 7 put the result in the frame.  Here the index and the loop counter are
     separate locals (as in LoadFileMultiPass, whose result did land in QIZ at O3). */
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
	int r;
	int idx;
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
