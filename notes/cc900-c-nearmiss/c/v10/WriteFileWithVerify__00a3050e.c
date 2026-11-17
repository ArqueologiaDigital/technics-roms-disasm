/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_2m266a.c (2026-11-16-72-p6-r13)
   sha256 00a3050edbce2126ea4971740c663aeb953b28ceeeca880ccd8150667bf4e0e6 (tar-sha256); compiled at -O3 -Xr */
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

    r = 0;
    cur = GetCurrentFileIndex();
    if (cur < 0) return -104;
    total = 0;
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordValid(FileIO_TypeProbeOrder[i]) != 0)
            total += UpdateFileEntry(cur, FileIO_TypeProbeOrder[i]);
    }
    if (FileIO_GetDiskFreeSpace() < total) return -101;
    e = GetFileEntryPtr(idx);
    FileIO_FormatFileIndex(name1, (unsigned char)idx, e);
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
