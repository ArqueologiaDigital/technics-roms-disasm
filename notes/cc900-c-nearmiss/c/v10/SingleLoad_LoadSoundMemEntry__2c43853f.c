/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_4m266a.c (2026-11-16-88-p6-r16)
   sha256 2c43853f1dedfbd12a11e05e21969dd7992b9ef6e52ead7dbb58fafe9b824104 (tar-sha256); compiled at -O3 -Xr
   cc900-name: SlStrRb4=SingleLoad_LoadPanelMemory_Str_rb_4 */
extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern void FileIO_ReadHeader(char *, char *, char);
extern int FileIO_OpenWithMode(char *, char *);
extern int FileIO_ReturnError(void);
extern void FileIO_CloseHandle(void);
extern int FileIO_SeekAndReadBlock(unsigned long, int);
extern void FileIO_ReadBlock(void *, unsigned long);
extern int FileIO_CheckRegionSignature(unsigned char);
extern void PreTmLoadEntry(int, int);
extern void PostTmLoadEntry(int, int, int);
extern unsigned long Math_Multiply32(unsigned long, unsigned long);
extern char SlStrRb4[];
extern unsigned char ram_1e0000[];
int SingleLoad_LoadSoundMemEntry(unsigned int bank, unsigned int src)
{
    char name[10];
    char hdr[14];
    unsigned long o;
    unsigned long o2;
    unsigned int len;
    unsigned char nb;
    unsigned char sl;
    int cur;
    unsigned int s;
    int r;

    cur = GetCurrentFileIndex();
    if (cur < 0) return -104;
    FileIO_FormatFileIndex(name, (unsigned char)cur, GetFileEntryPtr(cur));
    FileIO_ReadHeader(hdr, name, 4);
    if (FileIO_OpenWithMode(hdr, SlStrRb4) < 0) return FileIO_ReturnError();
    if (FileIO_CheckRegionSignature(4) == 0) {
        FileIO_CloseHandle();
        return -102;
    }
    s = src;
    if (bank < 40) {
        len = 470;
        o = Math_Multiply32(bank, 470);
        o += 16;
        o2 = Math_Multiply32(s, 470);
        o2 += 16;
        nb = s / 20;
        sl = s % 20;
    } else {
        bank -= 40;
        s -= 40;
        len = 80;
        o = (unsigned long)bank * 80;
        o += 0x4aa7;
        o2 = (unsigned long)s * 80;
        o2 += 0x4aa7;
        nb = 64;
        sl = s;
    }
    r = FileIO_SeekAndReadBlock(o, 0);
    if (r >= 0) {
        PreTmLoadEntry(nb, sl);
        FileIO_ReadBlock(ram_1e0000 + o2, len);
        r = FileIO_ReturnError();
        PostTmLoadEntry(nb, sl, r);
    }
    FileIO_CloseHandle();
    return r;
}
