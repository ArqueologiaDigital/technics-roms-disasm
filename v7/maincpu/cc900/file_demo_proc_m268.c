/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern long ram_25d6c;
extern long FileIO_DiskInfoInit;
extern void GetDiskFreeSpace(long *, long *);
extern long GetEncodedFreeSpaceData(void);
extern int FileIO_ReadByte(void);
extern int ReadVariableLengthInt(void);
extern unsigned char ram_25db6;
extern unsigned char FileIO_DiskInfoInit_MediaType;
extern unsigned char GetMediaType(void);
extern unsigned char GetDiskSizeInfo(void);

long GetEncodedFreeSpaceData(void)
{
    long *p = &ram_25d6c;
    if (FileIO_DiskInfoInit == *p) GetDiskFreeSpace(p, p + 1);
    return ram_25d6c;
}

int ReadVariableLengthInt(void)
{
    unsigned long v = 0;
    int c;
    while ((c = FileIO_ReadByte()) > 0x7f) {
        v += (long)(c & 0x7f);
        v <<= 7;
    }
    if (c < 0) return -1;
    v += (long)c;
    return (int)(v > 0x7fff ? 0x7fff : v);
}

unsigned char GetDiskSizeInfo(void)
{
    if (FileIO_DiskInfoInit_MediaType == ram_25db6) ram_25db6 = GetMediaType();
    return ram_25db6;
}

/* cc900-module: FileIO_BuildFileIndex FileIO_BuildFilePath FileIO_CopyString FileIO_FindPathSeparator */
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern int FileIO_OpenWithMode(char *, char *);
extern int FileIO_OpenWithBuiltPath(char *name, char *mode);
struct ffblk { unsigned char attr; char pad; long size; char name[260]; };
extern int _findnext(long, struct ffblk *);
extern int _findclose(long);
extern long ram_27416;
extern int FileIO_FindNextMatch(char *name, long *size);

int FileIO_OpenWithBuiltPath(char *name, char *mode)
{
	char path[140];

	FileIO_CopyString(path, (char *)0x272d2);
	FileIO_BuildFilePath(path, (char *)0x272f2);
	FileIO_BuildFilePath(path, name);
	return FileIO_OpenWithMode(path, mode);
}
int FileIO_FindNextMatch(char *name, long *size)
{
	struct ffblk fb;

	if (_findnext(ram_27416, &fb) != 0) {
		*name = 0;
		*size = 0;
		_findclose(ram_27416);
		ram_27416 = -1;
		return -1;
	}
	FileIO_CopyString(name, fb.name);
	if (fb.attr & 0x10)
		*size = -1;
	else
		*size = fb.size;
	return 0;
}

/* cc900-module: ReadFieldToBuffer ReadVariableLengthInt */
extern char ram_25b90[];
extern void ReadFieldToBuffer(int len, char *buf);
extern void FileIO_SeekAndReadBlock(long, int);
extern int FileIO_ReturnError(void);
extern char *ParseSMFTrackName(void);
extern int TrimAndFormatFilename(int len, unsigned char *s, unsigned char sep);

char *ParseSMFTrackName(void)
{
    int len;
    int status;
    int c;

    len = 0;
    ram_25b90[0] = 0;
    status = 0;
    while (ReadVariableLengthInt() == 0) {
        c = FileIO_ReadByte();
        if (c == 0xff) {
            status = FileIO_ReadByte();
            len = ReadVariableLengthInt();
            if (status == 3) {
                ReadFieldToBuffer(len, ram_25b90);
                len = 0;
            }
            status = 0;
        } else if (c == 0xf0 || c == 0xf7) {
            len = ReadVariableLengthInt();
            status = 0;
        } else if (c >= 0xc0 && c <= 0xdf) {
            len = 2;
            status = c;
        } else if (c >= 0x80 && c <= 0xef) {
            len = 3;
            status = c;
        } else if (c <= 0x7f) {
            if (status >= 0xc0 && status <= 0xdf)
                len = 1;
            else
                len = 2;
        }
        if (len > 0)
            FileIO_SeekAndReadBlock(len, 1);
        if (FileIO_ReturnError() < 0)
            return 0;
    }
    return ram_25b90;
}
int TrimAndFormatFilename(int len, unsigned char *s, unsigned char sep)
{
	unsigned char buf[128];
	int i;
	unsigned char *p;
	unsigned char c;
	unsigned char *q;

	s[len] = 0;
	for (i = 0; i < len; i++) {
		p = &s[i];
		c = *p;
		if (c < 0x20)
			*p = ' ';
		else if (c == sep) {
			*p = 0;
			break;
		}
	}
	while (--i >= 0) {
		q = &s[i];
		if (*q != ' ')
			break;
		*q = 0;
	}
	if (*s == ' ') {
		FileIO_CopyString((char *)buf, (char *)s);
		for (i = 0; buf[i] == ' '; i++)
			;
		FileIO_CopyString((char *)s, (char *)&buf[i]);
	}
	return 0;
}

extern int FileIO_CheckMediaIsWritable(void);

int FileIO_CheckMediaIsWritable(void)
{
  unsigned char t;
  t = GetMediaType();
  if (t != 2 && t != 3) return -1;
  return 0;
}

/* cc900-module: BuildPageRecords BuildSecondPageRecords FileIO_ScanDirEntries FileIO_ValidateModeAndRange ValidateFileRange ValidateFileRangeAlt ValidateFileRangeType5 ValidateFileSelectionIndex */
extern int ram_271ec, ram_271ee, FILE_LIST_LAST, ram_272ca;
extern int BuildPageRecords(void);
extern void BuildPageRecordsAlt(void);
extern int FileIO_ScanDirEntries(void);
extern void FileIO_InitWallpaperNav(void);
extern int BuildSecondPageRecords(void);
extern void GetFileCountEncoded(void);
extern int ram_25ea8, ram_271ea, ram_272c8;
extern int ValidateFileRangeAlt(int i);
extern int FileIO_GetCurrentFileIndex_Alt(void);
extern int FileIO_ValidateModeAndRange(int i);
extern int FileIO_GetCurrentWallpaperIndex(void);
extern int ValidateFileSelectionIndex(int i);
extern int GetCurrentFileIndex(void);
extern int ValidateFileRangeType5(int i);
extern int GetCurrentFileIndexAlt(void);
extern int ValidateFileRange(int i);
extern int GetFirstPageBase(void);

void BuildPageRecordsAlt(void)
{
	int n;
	int last;

	ram_271ee = 0;
	FILE_LIST_LAST = 59;
	n = BuildPageRecords();
	last = 0;
	if (n > 0)
		last = n - 1;
	ram_271ec = last;
	if (FILE_LIST_LAST > last)
		FILE_LIST_LAST = last;
}
void FileIO_InitWallpaperNav(void)
{
	int n;
	int last;

	ram_271ee = 0;
	FILE_LIST_LAST = 9;
	n = FileIO_ScanDirEntries();
	last = 0;
	if (n > 0)
		last = n - 1;
	ram_272ca = last;
	if (FILE_LIST_LAST > last)
		FILE_LIST_LAST = last;
}
void GetFileCountEncoded(void)
{
	int n;
	int last;

	ram_271ee = 0;
	FILE_LIST_LAST = 59;
	n = BuildSecondPageRecords();
	last = 0;
	if (n > 0)
		last = n - 1;
	ram_271ec = last;
	if (FILE_LIST_LAST > last)
		FILE_LIST_LAST = last;
}
int FileIO_GetCurrentFileIndex_Alt(void)
{
	if (ValidateFileRangeAlt(ram_271ea) != 0)
		return -104;
	return ram_271ea;
}
int FileIO_GetCurrentWallpaperIndex(void)
{
	if (FileIO_ValidateModeAndRange(ram_272c8) != 0)
		return -104;
	return ram_272c8;
}
int GetCurrentFileIndex(void)
{
	if (ValidateFileSelectionIndex(ram_25ea8) != 0)
		return -104;
	return ram_25ea8;
}
int GetCurrentFileIndexAlt(void)
{
	if (ValidateFileRangeType5(ram_271ea) != 0)
		return -104;
	return ram_271ea;
}
int GetFirstPageBase(void)
{
	if (ValidateFileRange(ram_271ea) != 0)
		return -104;
	return ram_271ea;
}

/* cc900-module: FDC_CMD_SEND FDC_Set_Status SOME_DELAY */
extern void FileIO_CopyString_WriteNull(char *d, char *s, unsigned int n);

void FileIO_CopyString_WriteNull(char *d, char *s, unsigned int n)
{
    while (n != 0 && *s != 0) {
        *d++ = *s++;
        n--;
    }
    while (n != 0) {
        *d++ = 0;
        n--;
    }
}
