/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_15m266a.c (2026-11-18-1-p6-r33)
   sha256 0e110d75c5f26f42f32c3c81b22c007f5f3a95fe8d06aa427ae52817e1bcdf2c (tar-sha256); compiled at -Xr */
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
