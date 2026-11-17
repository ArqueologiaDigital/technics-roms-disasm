/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_14m266a.c (2026-11-17-16-p6-r31)
   sha256 a2a95e7c4c707b35ac8d8769786885f6270e382e47ff2a908377a3233ee5eec0 (tar-sha256); compiled at -O3 -Xr */
struct RegLdr {
    unsigned char id;
    unsigned char pad;
    int (*fn)(char *);
};
extern struct RegLdr FileIO_RegionLoaders[];
extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern char FileIO_WriteRecordName_Done(char);
extern char FileIO_CheckRecordValid(char);
extern int FileIO_LoadSongRegion8(char *);
extern void FileIO_GetRecordByType_Lookup(void *);
int FileIO_ParseDirectoryEntry(void)
{
    char buf[6];
    void *e;
    int n;
    int i;
    int r;
    int t;

    r = 0;
    i = GetCurrentFileIndex();
    if (i < 0) return -104;
    e = GetFileEntryPtr(i);
    FileIO_FormatFileIndex(buf, (unsigned char)i, e);
    n = 0;
    i = 0;
    do {
        if (FileIO_WriteRecordName_Done(FileIO_RegionLoaders[i].id) != 0 &&
            FileIO_CheckRecordValid(FileIO_RegionLoaders[i].id) != 0) {
            t = FileIO_RegionLoaders[i].fn(buf);
            if (t >= 0) n++;
            else if (r >= 0) r = t;
        }
        i++;
    } while (i < 8);
    if (FileIO_WriteRecordName_Done(2) != 0 && FileIO_CheckRecordValid(8) != 0 &&
        FileIO_CheckRecordValid(9) != 0) {
        t = FileIO_LoadSongRegion8(buf);
        if (t >= 0) n++;
        else if (r >= 0) r = t;
    }
    if (n > 0) FileIO_GetRecordByType_Lookup(e);
    else if (r >= 0) r = -104;
    return r;
}
