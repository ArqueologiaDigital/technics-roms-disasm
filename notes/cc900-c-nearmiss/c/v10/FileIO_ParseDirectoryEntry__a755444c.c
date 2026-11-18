/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_15m266b.c (2026-11-18-1-p6-r33)
   sha256 a755444c324f97a5e36a099d8cc8ec111ce67bac96b251ff70fcf41e386b7219 (tar-sha256); compiled at -O3 -Xr */
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
    char buf[10];
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
    for (i = 0; i < 8; i++) {
        if (FileIO_WriteRecordName_Done(((struct RegLdr *)((char *)FileIO_RegionLoaders + i * 6))->id) != 0 &&
            FileIO_CheckRecordValid(((struct RegLdr *)((char *)FileIO_RegionLoaders + i * 6))->id) != 0) {
            t = ((struct RegLdr *)((char *)FileIO_RegionLoaders + i * 6))->fn(buf);
            if (t < 0) {
                if (r >= 0) r = t;
            } else {
                n++;
            }
        }
    }
    if (FileIO_WriteRecordName_Done(2) != 0 && FileIO_CheckRecordValid(8) != 0 &&
        FileIO_CheckRecordValid(9) != 0) {
        t = FileIO_LoadSongRegion8(buf);
        if (t < 0) {
            if (r >= 0) r = t;
        } else {
            n++;
        }
    }
    if (n > 0) FileIO_GetRecordByType_Lookup(e);
    else if (r >= 0) r = -104;
    return r;
}
