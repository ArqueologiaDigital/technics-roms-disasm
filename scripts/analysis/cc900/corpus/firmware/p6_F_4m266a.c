/* lane_p6 helper F, round 4, module 266 (demo/file_demo_proc.s), form a.
   The single-load bank / entry loaders, which reach FileIO_CheckRegionSignature with calr.
   New this round: the RAM buffers they read into are symbols (ram_1e0000, ram_b0000, ram_1ed350), so V4.23 writes
   `lda xwa,sym` for the buffer address as the ROM does, while the ROM's integer constants stay `ld` (-Xr).
   SingleLoad_LoadSoundMemEntry is new.  Form a calls Math_Multiply32 by name; form b writes `*`.
   __near: 16-bit absolute operand; plain: 24-bit (or a ROM label).  One declarator per __near declaration. */

/* cc900-module: FileIO_CheckRegionSignature FileIO_ReadHeaderAt4 */
/* cc900-name: SlStrRb=SingleLoad_LoadPanelMemory_Str_rb */
/* cc900-name: SlStrRb2=SingleLoad_LoadPanelMemory_Str_rb_2 */
/* cc900-name: SlStrRb4=SingleLoad_LoadPanelMemory_Str_rb_4 */
/* cc900-name: SlStrRb5=SingleLoad_LoadPanelMemory_Str_rb_5 */

extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern long UpdateFileEntry(int, char);
extern void FileIO_ReadHeader(char *, char *, char);
extern int FileIO_OpenWithMode(char *, char *);
extern int FileIO_ReturnError(void);
extern void FileIO_CloseHandle(void);
extern int FileIO_SeekAndReadBlock(unsigned long, int);
extern void FileIO_ReadBlock(void *, unsigned long);
extern int FileIO_CheckRegionSignature(unsigned char);
extern int FileIO_ReadHeaderAt4(void);
extern unsigned long SeqLoad_ProcessDataBlock(int);
extern long SingleLoad_PrepareSongSlot(int);
extern void SingleLoad_FinishSongLoad(int, int);
extern void SetSongSlotValue(unsigned int, int);
extern void PreTmLoadEntry(int, int);
extern void PostTmLoadEntry(int, int, int);
extern void PostTmLoadEntry_Return(int);
extern void TmFlashWrite_ValidateParams(int, int);
extern void PanelMemory_PreBankLoad(int);
extern void PanelMemory_PostBankLoad(int, int);
extern unsigned long Math_Multiply32(unsigned long, unsigned long);

extern char SlStrRb[];
extern char SlStrRb2[];
extern char SlStrRb4[];
extern char SlStrRb5[];
extern unsigned char SEQ_SONG_SLOTS[][2048];
extern unsigned char ram_1e0000[];
extern unsigned char ram_b0000[];
extern unsigned char ram_1ed350[];

int SingleLoad_LoadSong(unsigned int slot)
{
    char name[10];
    char hdr[14];
    unsigned long size;
    int cur;
    int r;
    long p;

    cur = GetCurrentFileIndex();
    if (cur < 0) return -104;
    FileIO_FormatFileIndex(name, (unsigned char)cur, GetFileEntryPtr(cur));
    FileIO_ReadHeader(hdr, name, 2);
    if (FileIO_OpenWithMode(hdr, SlStrRb2) < 0) return FileIO_ReturnError();
    if (FileIO_CheckRegionSignature(2) == 0) {
        r = -102;
    } else if (FileIO_ReadHeaderAt4() != 0) {
        r = -106;
    } else {
        size = SeqLoad_ProcessDataBlock((unsigned char)slot);
        if (size < UpdateFileEntry(GetCurrentFileIndex(), 2)) {
            r = -105;
        } else {
            p = SingleLoad_PrepareSongSlot((unsigned char)slot);
            FileIO_ReadBlock(SEQ_SONG_SLOTS[slot], 2048);
            FileIO_ReadBlock(ram_b0000 + p, size);
            r = FileIO_ReturnError();
            SingleLoad_FinishSongLoad((unsigned char)slot, r);
            if (r >= 0) SetSongSlotValue(slot, 0);
        }
    }
    FileIO_CloseHandle();
    return r;
}

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
        o = Math_Multiply32(bank, 9400);
        o += 16;
        o2 = Math_Multiply32(src, 9400);
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
            o = Math_Multiply32(bank, sz);
            o += 176;
            o2 = Math_Multiply32(src, sz);
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
