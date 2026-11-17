/* lane_p6 helper F, round 15, module 266 (demo/file_demo_proc.s), form a.  FileIO_ParseDirectoryEntry.
   Run r31: round 14 form a at -O3 has the ROM's code shape; three spots differ.
   - Frame: the ROM's is 16 bytes (ours 12): the name buffer is 10 bytes at +10.
   - The region table: the ROM indexes it with `muls WA,6` and a byte load `(XBC+WA)`, and the loader pointer with
     `muls BC,6; exts; add` from FileIO_TypeLoaderColumn; a struct subscript gave shift-add.  So both are read
     from byte arrays, `table + i * 6` (BRIEF2: a char-indexed plain array, and the `(char *)base + i*N` idiom).
   - Result test: the ROM tests `t >= 0` with the count increment as the jump target, i.e. the error branch is
     written first: `if (t < 0) { if (r >= 0) r = t; } else n++;`.
   Loop as a do-while; record callees `char f(char)` (round 14 form a's choice). */

/* cc900-module: FileIO_LoadSongRegion8 */

extern unsigned char FileIO_RegionLoaders[];
extern char FileIO_TypeLoaderColumn[];
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
    i = 0;
    do {
        if (FileIO_WriteRecordName_Done(FileIO_RegionLoaders[i * 6]) != 0 &&
            FileIO_CheckRecordValid(FileIO_RegionLoaders[i * 6]) != 0) {
            t = (*(int (**)(char *))(FileIO_TypeLoaderColumn + i * 6))(buf);
            if (t < 0) {
                if (r >= 0) r = t;
            } else {
                n++;
            }
        }
        i++;
    } while (i < 8);
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
