/* Phase 6, lane_p6 helper L, round 8, form b: module 266, ReadDualFile with the result a `register int` (to pull it
   into QIZ) and round 7's shared index / counter. */
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
	register int r;
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
