/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_4m266b.c (2026-11-16-88-p6-r16)
   sha256 a1663c2f88bf71ca1147424776baaf1ec67893af12d77bb32e9d4acff9c1ddab (tar-sha256); compiled at -O3 -Xr
   cc900-name: SlStrRb=SingleLoad_LoadPanelMemory_Str_rb */
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
extern void PanelMemory_PreBankLoad(int);
extern void PanelMemory_PostBankLoad(int, int);
extern char SlStrRb[];
extern unsigned char ram_1ed350[];
int SingleLoad_LoadPanelMemBank(unsigned int bank, unsigned int src)
{
    char name[10];
    char hdr[14];
    unsigned long o2;
    unsigned long sz;
    int cur;
    unsigned long o;
    int r;

    cur = GetCurrentFileIndex();
    if (cur < 0) return -104;
    FileIO_FormatFileIndex(name, (unsigned char)cur, GetFileEntryPtr(cur));
    FileIO_ReadHeader(hdr, name, 1);
    if (FileIO_OpenWithMode(hdr, SlStrRb) < 0) return FileIO_ReturnError();
    if (FileIO_CheckRegionSignature(1) == 0) {
        r = -102;
    } else {
        o = bank;
        o <<= 4;
        o += 16;
        o2 = src;
        o2 <<= 4;
        o2 += 16;
        r = FileIO_SeekAndReadBlock(o, 0);
        if (r >= 0) {
            PanelMemory_PreBankLoad((unsigned char)src);
            FileIO_ReadBlock(ram_1ed350 + o2, 16);
            sz = *(unsigned int *)(ram_1ed350 + 13);
            sz <<= 3;
            o = bank * sz;
            o += 176;
            o2 = src * sz;
            o2 += 176;
            FileIO_SeekAndReadBlock(o, 0);
            FileIO_ReadBlock(ram_1ed350 + o2, sz);
            r = FileIO_ReturnError();
            PanelMemory_PostBankLoad((unsigned char)src, r);
        }
    }
    FileIO_CloseHandle();
    return r;
}
