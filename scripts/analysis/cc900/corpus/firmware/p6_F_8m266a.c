/* lane_p6 helper F, round 8, module 266 (demo/file_demo_proc.s), form a.
   WriteFileWithVerify: round 3 form b (second block's entry pointer in its own variable e2) matched the ROM up to
   the first loop's UpdateFileEntry, where the ROM loads the file number (WA) before the table byte (C); the
   table byte now goes through a plain local (lane_sub's spelling (b): a local is loaded in argument order). */

extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern unsigned char FileIO_CheckRecordValid(char);
extern unsigned char FileIO_CheckRecordByFile(int, char);
extern long UpdateFileEntry(int, char);
extern long FileIO_GetDiskFreeSpace(void);
extern void FileIO_ReadHeader(char *, char *, char);
extern int FileIO_OpenDefault(char *);
extern int FileIO_CompareFiles(char *, char *);
extern unsigned char FileIO_TypeProbeOrder[];

int WriteFileWithVerify(int idx)
{
    char name1[10];
    char name2[10];
    char hdr1[14];
    char hdr2[14];
    int cur;
    int r;
    long total;
    int i;
    void *e;
    void *e2;
    unsigned char t;

    r = 0;
    cur = GetCurrentFileIndex();
    if (cur < 0) return -104;
    total = 0;
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordValid(FileIO_TypeProbeOrder[i]) != 0) {
            t = FileIO_TypeProbeOrder[i];
            total += UpdateFileEntry(cur, t);
        }
    }
    if (FileIO_GetDiskFreeSpace() < total) return -101;
    e2 = GetFileEntryPtr(idx);
    FileIO_FormatFileIndex(name1, (unsigned char)idx, e2);
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordByFile(idx, FileIO_TypeProbeOrder[i]) != 0) {
            FileIO_ReadHeader(hdr1, name1, FileIO_TypeProbeOrder[i]);
            r = FileIO_OpenDefault(hdr1);
            if (r < 0) return r;
        }
    }
    e = GetFileEntryPtr(cur);
    FileIO_FormatFileIndex(name1, (unsigned char)cur, e);
    FileIO_FormatFileIndex(name2, (unsigned char)idx, e);
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordValid(FileIO_TypeProbeOrder[i]) != 0) {
            FileIO_ReadHeader(hdr1, name1, FileIO_TypeProbeOrder[i]);
            FileIO_ReadHeader(hdr2, name2, FileIO_TypeProbeOrder[i]);
            r = FileIO_CompareFiles(hdr2, hdr1);
            if (r < 0) break;
        }
    }
    return r;
}
