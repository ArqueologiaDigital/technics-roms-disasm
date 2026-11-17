/* lane_p6 helper F, round 14, module 266 (demo/file_demo_proc.s), form b: FileIO_ParseDirectoryEntry as form a,
   with the record callees declared as the tree's matched C declares them (`char f(int)`, composer_filters_m269.c;
   the constant arguments 2 / 8 / 9 are loaded as words in the ROM) and the region loop a `for`. */

/* cc900-module: FileIO_LoadSongRegion8 */

struct RegLdr {
    unsigned char id;
    unsigned char pad;
    int (*fn)(char *);
};
extern struct RegLdr FileIO_RegionLoaders[];
extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern char FileIO_WriteRecordName_Done(int);
extern char FileIO_CheckRecordValid(int);
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
    for (i = 0; i < 8; i++) {
        if (FileIO_WriteRecordName_Done(FileIO_RegionLoaders[i].id) != 0 &&
            FileIO_CheckRecordValid(FileIO_RegionLoaders[i].id) != 0) {
            t = FileIO_RegionLoaders[i].fn(buf);
            if (t >= 0) n++;
            else if (r >= 0) r = t;
        }
    }
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
