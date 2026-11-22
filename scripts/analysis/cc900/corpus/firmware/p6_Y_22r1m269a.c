/* lane_p6 helper Y, round 22r1, form a: module 269 (file_io/disk_operations.s), the file-name ApFunctions that
   sat inside pool22_X's DiskInfoFunc span (never pooled on their own): SongNameFunc, SaveFileNameNumFunc,
   SaveFileNameFunc, CurFileNameFunc (Num / Cur are twins).  ROM `ld xR, 0x88nn` spelled as constants, `lda`
   as the __near array (HANDOFF-2026-11-18).  FileIO_ReadHeader_ParseLoop takes two stack words (retd 4).
   Form a: SaveFileNameFunc's switch in reverse compare order (helper X's lesson); the pad loops on the array.
   cc900-options: -O3 -Xr
*/
/* cc900-module: InitializeOperationState */

#define EVT_PAINT         0x1c0000bL
#define EVT_PARA_DRAW      0x1c0000fL
#define EVT_GET_STRING     0x1e0003aL
#define EVT_SET_STRING     0x1e00086L

extern __near char ram_880e[];
extern __near char ram_8850[];
extern __near char ram_8870[];
extern unsigned char CType_ClassTable[];

extern long ApPostEvent(long, long, long);
extern int GetFirstPageBase(void);
extern int GetCurrentFileIndex(void);
extern void InitializeOperationState(int);
extern char *GetFileEntryByIndex(int);
extern char *GetFileEntryPtr(int);
extern char *FileIO_GetRecordByType(void);
extern void FileIO_CopyString(char *, char *);
extern void FileIO_GetRecordType_Extended(char *);
extern void FileIO_GetRecordByType_Lookup(char *);
extern void FileIO_ReadHeader_ParseLoop(char *, char *, int, int, int);

long SongNameFunc(long obj, long evt, long p)
{
	int i;
	char *s;

	if (evt == EVT_PAINT) {
		i = GetFirstPageBase();
		if (i >= 0) {
			InitializeOperationState(0);
			FileIO_CopyString(ram_880e, GetFileEntryByIndex(i));
			ram_880e[30] = 0;
			for (s = &ram_880e[29]; *s == ' ' && s > ram_880e; s--)
				*s = 0;
			FileIO_GetRecordType_Extended(ram_880e);
		} else {
			ram_880e[0] = 0;
		}
		ApPostEvent(p, EVT_PARA_DRAW, 0x880eL);
	}
	return 0;
}

long SaveFileNameNumFunc(long obj, long evt, long p)
{
	int i;

	if (evt == EVT_PAINT) {
		i = GetCurrentFileIndex();
		if (i >= 0)
			FileIO_ReadHeader_ParseLoop((char *)0x8850L, FileIO_GetRecordByType(), i + 1, 0, 6);
		else
			ram_8850[0] = 0;
		ApPostEvent(p, EVT_PARA_DRAW, 0x8850L);
	}
	return 0;
}

long SaveFileNameFunc(long obj, long evt, long p)
{
	int k;
	unsigned char c;

	switch (evt) {
	case EVT_PAINT:
		FileIO_CopyString(ram_8850, FileIO_GetRecordByType());
		FileIO_GetRecordType_Extended((char *)0x8850L);
		ApPostEvent(p, EVT_PARA_DRAW, 0x8850L);
		break;
	case EVT_GET_STRING:
		FileIO_CopyString(ram_8850, FileIO_GetRecordByType());
		for (k = 0; k < 6 && (c = ram_8850[k]) != 0; k++) {
			if ((CType_ClassTable[c] & 7) == 0)
				ram_8850[k] = '_';
		}
		for (; k < 6; k++)
			ram_8850[k] = '_';
		ram_8850[6] = 0;
		ApPostEvent(p, EVT_SET_STRING, (long)ram_8850);
		break;
	case EVT_SET_STRING:
		FileIO_CopyString((char *)0x8850L, (char *)p);
		FileIO_GetRecordByType_Lookup((char *)0x8850L);
		break;
	}
	return 0;
}

long CurFileNameFunc(long obj, long evt, long p)
{
	int i;

	if (evt == EVT_PAINT) {
		i = GetCurrentFileIndex();
		if (i >= 0)
			FileIO_ReadHeader_ParseLoop((char *)0x8870L, GetFileEntryPtr(i), i + 1, 0, 6);
		else
			ram_8870[0] = 0;
		ApPostEvent(p, EVT_PARA_DRAW, 0x8870L);
	}
	return 0;
}
