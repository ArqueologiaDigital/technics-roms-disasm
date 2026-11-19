/* Phase 6, lane_p6 helper L, round 7, form a: module 266 (demo/file_demo_proc.s), new.
   - ReadDualFile: build the two numbered names (the current file's entry, and the given name) and, for each of the
     ten probe types valid for this record, read both headers and copy-and-open; stop at the first negative
     result; return the last result (0 if none).  The ROM keeps the result in QIZ and uses IZ for the file index
     and then the loop counter: ONE int for both (idiom 4).  Arrays declared highest slot first. */
/* (no module-local callee) */

extern char FileIO_TypeProbeOrder[];
extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern char FileIO_CheckRecordValid(char);
extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_CopyAndOpen(char *, char *);
extern int ReadDualFile(char *name);

int ReadDualFile(char *name)
{
	char n2[10];
	char n1[10];
	char h2[14];
	char h1[14];
	int r;
	int i;

	r = 0;
	i = GetCurrentFileIndex();
	if (i < 0)
		return -104;
	FileIO_FormatFileIndex(n1, (unsigned char)i, GetFileEntryPtr(i));
	FileIO_FormatFileIndex(n2, (unsigned char)i, name);
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

/* LoadFileMultiPass: ReadDualFile's sibling with one name: probe the ten types until one opens with a negative
   result (returned), then build the record's own name, open it "wb" (failure: FileIO_ReturnError's result), save
   the part, close, and on a negative save reopen the default.  The ROM stores the part as a word and widens its
   low byte (a K&R char parameter); IZ holds the low byte of the index, then the loop counter (one variable). */
extern char MultiPass_LoopNext_Str_wb[];
extern int FileIO_OpenDefault(char *);
extern void *FileIO_GetRecordByType(int);
extern int FileIO_ReturnError(void);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int SeqSave_PreparePartData(int);
extern void FileIO_CloseHandle(void);

int LoadFileMultiPass(part)
unsigned char part;
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
	r = SeqSave_PreparePartData(part);
	FileIO_CloseHandle();
	if (r < 0)
		FileIO_OpenDefault(hd);
	return r;
}
