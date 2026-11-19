/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void SLIDE_Parse_Header(long, unsigned char *);
extern void FileIO_SeekAndReadBlock(long, int);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
extern unsigned char *FileIO_HeaderAt4_ExpectedPtr;

void Demo_ParseSlideHeader(unsigned char i)
{
    long v;
    if ((v = ((long *)0x9c4000)[i]) != 0) SLIDE_Parse_Header(v, (unsigned char *)0x69800);
}

int FileIO_ReadHeaderAtF(void)
{
    int ok = 1;
    int c;
    FileIO_SeekAndReadBlock(15, 0);
    c = FileIO_ReadByte();
    if (c < 0 || (unsigned char)c != 8) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}

int FileIO_ReadHeaderAt4(void)
{
    int ok = 1;
    int c;
    FileIO_SeekAndReadBlock(4, 0);
    c = FileIO_ReadByte();
    if (c < 0 || (char)c != (char)*FileIO_HeaderAt4_ExpectedPtr) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}

struct democol { unsigned char title; unsigned char entry; };
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near DEMO_CURRENT_SONG;
extern struct democol DemoSong_TitleCol[];
extern void UI_ChangeTitleByIndex(char i);
extern void Demo_SelectEntry_DrawSecondary(void);

void Demo_SelectEntry_DrawSecondary(void)
{
    if (!(DEMO_CONTROL_FLAGS & 8)) return;
    if (ACTIVE_TITLE != 0xe4) UI_ChangeTitleByIndex(DemoSong_TitleCol[DEMO_CURRENT_SONG].title);
}

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
extern int FileIO_ParseDirectoryEntry(void);

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

struct ffblk { unsigned char b[266]; };
extern int GetFirstPageBase(void);
extern char *GetRecordPtrForFile(int);
extern long _findfirst(char *, struct ffblk *);
extern void _findclose(long);
extern int FileIO_CopyAndOpen(char *, char *);
extern int SearchAndOpen(char *name);

int SearchAndOpen(char *name)
{
    struct ffblk f;
    int pg;
    long h;
    pg = GetFirstPageBase();
    if (pg < 0) return -104;
    h = _findfirst(name, &f);
    if (h < 0) return FileIO_CopyAndOpen(GetRecordPtrForFile(pg), name);
    _findclose(h);
    return -10;
}
