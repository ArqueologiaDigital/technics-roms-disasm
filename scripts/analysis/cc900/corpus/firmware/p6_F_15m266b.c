/* lane_p6 helper F, round 15, module 266 (demo/file_demo_proc.s), form b: FileIO_ParseDirectoryEntry as form a
   (10-byte buffer, error branch first, `char` record callees), with the table kept as the struct array and read
   through `(char *)FileIO_RegionLoaders + i * 6` (the muls idiom on a cast base), and a `for` loop. */

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
