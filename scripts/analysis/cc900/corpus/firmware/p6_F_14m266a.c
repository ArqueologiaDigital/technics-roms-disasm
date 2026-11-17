/* lane_p6 helper F, round 14, module 266 (demo/file_demo_proc.s), form a.  New: FileIO_ParseDirectoryEntry.
   For the current file entry: format its index into a 6-byte name buffer, then for each of the 8 regions whose
   record is present and valid call the region's loader from FileIO_RegionLoaders (6-byte records: region byte,
   pad, loader pointer at +2 = FileIO_TypeLoaderColumn) and count the successes, keeping the first error; then the
   song region (8/9) the same way.  If anything loaded, look the record up by type; else report -104 (0xff98).
   Registers in the ROM: the index / loop counter in IZ, the result in QIZ, the entry pointer and the count in
   frame slots (+4, +8), the name buffer at +10.
   Form a: the record callees take a `char` (the loop passes the table byte in A with no extension; lane_sub's
   spelling (c)); the loop is a do-while (no entry test at either option set). */

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
