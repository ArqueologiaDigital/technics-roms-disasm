/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_1b.c (2026-11-16-55-p6-r10)
   sha256 a518fdcf192eae41509fa2813337216e1a2cc69827c693dcbb511205ae502c10 (tar-sha256); compiled at -O3 -Xr */
extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern unsigned char FileIO_CheckRecordValid(unsigned char);
extern unsigned char FileIO_CheckRecordByFile(int, unsigned char);
extern void FileIO_ReadHeader(char *, char *, unsigned char);
extern int FileIO_CopyAndOpen(char *, char *);
extern unsigned char FileIO_TypeProbeOrder[];
int ReadDualFileEx(int idx)
{
    int r;
    int i;
    int cur;
    void *ea;
    void *eb;
    char hdr2[14];
    char hdr1[14];
    char name2[10];
    char name1[10];

    r = 0;
    cur = GetCurrentFileIndex();
    if (cur < 0) return -104;
    ea = GetFileEntryPtr(cur);
    eb = GetFileEntryPtr(idx);
    FileIO_FormatFileIndex(name1, (unsigned char)idx, eb);
    FileIO_FormatFileIndex(name2, 20, eb);
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordByFile(idx, FileIO_TypeProbeOrder[i]) != 0) {
            FileIO_ReadHeader(hdr1, name1, FileIO_TypeProbeOrder[i]);
            FileIO_ReadHeader(hdr2, name2, FileIO_TypeProbeOrder[i]);
            if ((r = FileIO_CopyAndOpen(hdr1, hdr2)) < 0) goto out;
        }
    }
    FileIO_FormatFileIndex(name1, (unsigned char)cur, ea);
    FileIO_FormatFileIndex(name2, (unsigned char)idx, ea);
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordValid(FileIO_TypeProbeOrder[i]) != 0) {
            FileIO_ReadHeader(hdr1, name1, FileIO_TypeProbeOrder[i]);
            FileIO_ReadHeader(hdr2, name2, FileIO_TypeProbeOrder[i]);
            if ((r = FileIO_CopyAndOpen(hdr1, hdr2)) < 0) goto out;
        }
    }
    FileIO_FormatFileIndex(name1, 20, eb);
    FileIO_FormatFileIndex(name2, (unsigned char)cur, eb);
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordByFile(idx, FileIO_TypeProbeOrder[i]) != 0) {
            FileIO_ReadHeader(hdr1, name1, FileIO_TypeProbeOrder[i]);
            FileIO_ReadHeader(hdr2, name2, FileIO_TypeProbeOrder[i]);
            if ((r = FileIO_CopyAndOpen(hdr1, hdr2)) < 0) goto out;
        }
    }
out:
    return r;
}
