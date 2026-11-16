/* lane_p6 helper F, round 5, module 266 (demo/file_demo_proc.s), form b: as form a, with the record offset
   written index first (`i * 6 + base`, for the ROM's index in WA and base in XBC) and UpdateFileEntry's first
   argument given as an int expression instead.
   FileIO_SaveAllRegions: run 87 (form a) had the ROM's registers but read the record type as plain char, which
   V4.23 sign-extends before the char-parameter call; the type is now read as unsigned char (no extension, as in
   round 2's table bytes).  Its `cp QIZ,8` still waits for the translator fix (lane_vmb).
   WriteFileWithVerify: run 87 differs only in the argument order of UpdateFileEntry (the ROM loads the file
   number first); this form gives the table byte an int expression that the char parameter narrows.
   __near: 16-bit absolute operand; plain: 24-bit (or a ROM label).  One declarator per __near declaration. */

extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern unsigned char FileIO_CheckRecordValid(char);
extern unsigned char FileIO_CheckRecordByFile(int, char);
extern unsigned char FileIO_FormatName_Return(char);
extern long UpdateFileEntry(int, char);
extern long FileIO_GetDiskFreeSpace(void);
extern void FileIO_ReadHeader(char *, char *, char);
extern int FileIO_OpenDefault(char *);
extern int FileIO_CompareFiles(char *, char *);
extern void *FileIO_GetRecordByType(void);

extern unsigned char FileIO_TypeProbeOrder[];
struct SaveRec { unsigned char type; char pad; int (*fn)(char *); };
extern struct SaveRec SaveAll_RegionSaveRecs[];
typedef int (*SaveFn)(char *);
#define SREC_TYPE(i) (*((i) * 6 + (unsigned char *)SaveAll_RegionSaveRecs))
#define SREC_FN(i)   (*(SaveFn *)((i) * 6 + ((char *)SaveAll_RegionSaveRecs + 2)))

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
            total += UpdateFileEntry(cur + 0, FileIO_TypeProbeOrder[i]);
    }
    if (FileIO_GetDiskFreeSpace() < total) return -101;
    FileIO_FormatFileIndex(name1, (unsigned char)idx, GetFileEntryPtr(idx));
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

int FileIO_SaveAllRegions(void)
{
    char name[10];
    char hdr[14];
    int r;
    int cur;
    int i;
    void *e;

    r = 0;
    cur = GetCurrentFileIndex();
    if (cur < 0) return -104;
    e = GetFileEntryPtr(cur);
    FileIO_FormatFileIndex(name, (unsigned char)cur, e);
    for (i = 0; i < 8; i++) {
        if (FileIO_CheckRecordValid(SREC_TYPE(i)) != 0) {
            FileIO_ReadHeader(hdr, name, SREC_TYPE(i));
            r = FileIO_OpenDefault(hdr);
            if (r < 0) return r;
        }
    }
    FileIO_ReadHeader(hdr, name, 8);
    FileIO_OpenDefault(hdr);
    FileIO_ReadHeader(hdr, name, 9);
    FileIO_OpenDefault(hdr);
    e = FileIO_GetRecordByType();
    FileIO_FormatFileIndex(name, (unsigned char)cur, e);
    for (i = 0; i < 8; i++) {
        if (FileIO_FormatName_Return(SREC_TYPE(i)) != 0) {
            r = SREC_FN(i)(name);
            if (r < 0) break;
        }
    }
    if (r < 0) {
        for (i = 0; i < 8; i++) {
            if (FileIO_FormatName_Return(SREC_TYPE(i)) != 0) {
                FileIO_ReadHeader(hdr, name, SREC_TYPE(i));
                FileIO_OpenDefault(hdr);
            }
        }
    }
    return r;
}
