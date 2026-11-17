/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_4m266b.c (2026-11-16-88-p6-r16)
   sha256 a1663c2f88bf71ca1147424776baaf1ec67893af12d77bb32e9d4acff9c1ddab (tar-sha256); compiled at -O3 -Xr
   cc900-name: SlStrRb5=SingleLoad_LoadPanelMemory_Str_rb_5 */
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
extern void PostTmLoadEntry_Return(int);
extern void TmFlashWrite_ValidateParams(int, int);
extern char SlStrRb5[];
extern unsigned char ram_1e0000[];
int SingleLoad_LoadSoundMemBank(unsigned int bank, unsigned int src)
{
    char name[10];
    char hdr[14];
    unsigned long o2;
    unsigned int len;
    unsigned char nb;
    int cur;
    unsigned long o;
    int r;

    cur = GetCurrentFileIndex();
    if (cur < 0) return -104;
    FileIO_FormatFileIndex(name, (unsigned char)cur, GetFileEntryPtr(cur));
    FileIO_ReadHeader(hdr, name, 4);
    if (FileIO_OpenWithMode(hdr, SlStrRb5) < 0) return FileIO_ReturnError();
    if (FileIO_CheckRegionSignature(4) == 0) {
        FileIO_CloseHandle();
        return -102;
    }
    if (bank < 2) {
        len = 9400;
        o = (unsigned long)bank * 9400 + 16;
        o2 = (unsigned long)src * 9400;
        o2 += 16;
        nb = src;
    } else {
        len = 0x2927;
        o = 0x4980;
        o2 = 0x4980;
        nb = 64;
    }
    r = FileIO_SeekAndReadBlock(o, 0);
    if (r >= 0) {
        PostTmLoadEntry_Return(nb);
        FileIO_ReadBlock(ram_1e0000 + o2, len);
        r = FileIO_ReturnError();
        TmFlashWrite_ValidateParams(nb, r);
    }
    FileIO_CloseHandle();
    return r;
}
