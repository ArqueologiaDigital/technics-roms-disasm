/* lane_p6 helper F, round 2, module 266 (demo/file_demo_proc.s), form a.
   The region-signature checks and their calr callers (SingleLoad_LoadSong / _LoadSoundMemBank /
   _LoadPanelMemBank), and the refined file-set routines of round 1.
   Form a: char-parameter callees are prototyped `char` and the tables are unsigned char (round 1's
   unsigned char -> unsigned char argument got an extz the ROM lacks); a nested GetFileEntryPtr call is split
   into its own statement where the ROM evaluates it before the cast.  Scalar locals are declared in ascending
   stack order (V4.23 gives the first-declared scalar the lowest slot, the first-declared array the highest).
   __near: 16-bit absolute operand; plain: 24-bit (or a ROM label).  One declarator per __near declaration. */

extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern unsigned char FileIO_CheckRecordValid(char);
extern unsigned char FileIO_CheckRecordByFile(int, char);
extern unsigned char FileIO_FormatName_Return(char);
extern long UpdateFileEntry(int, char);
extern long FileIO_GetDiskFreeSpace(void);
extern void FileIO_ReadHeader(char *, char *, char);
extern int FileIO_OpenDefault(char *);
extern int FileIO_CopyAndOpen(char *, char *);
extern int FileIO_CompareFiles(char *, char *);
extern void *FileIO_GetRecordByType(void);
extern int FileIO_OpenWithMode(char *, char *);
extern int FileIO_ReturnError(void);
extern void FileIO_CloseHandle(void);
extern int FileIO_SeekAndReadBlock(unsigned long, int);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
extern void FileIO_ReadBlock(void *, unsigned long);
extern unsigned long SeqLoad_ProcessDataBlock(int);
extern long SingleLoad_PrepareSongSlot(int);
extern void SingleLoad_FinishSongLoad(int, int);
extern void SetSongSlotValue(unsigned int, int);
extern void PostTmLoadEntry_Return(int);
extern void TmFlashWrite_ValidateParams(int, int);
extern void PanelMemory_PreBankLoad(int);
extern void PanelMemory_PostBankLoad(int, int);
extern unsigned long Math_Multiply32(unsigned long, unsigned long);

extern unsigned char FileIO_TypeProbeOrder[];
struct SaveRec { unsigned char type; char pad; int (*fn)(char *); };
extern struct SaveRec SaveAll_RegionSaveRecs[];
struct SigRec { unsigned char *sig; unsigned int off; unsigned int len; };
extern struct SigRec FileIO_RegionSignatures[];
extern unsigned char *FileIO_HeaderAt4_ExpectedPtr;
extern char SingleLoad_LoadPanelMemory_Str_rb[];
extern char SingleLoad_LoadPanelMemory_Str_rb_2[];
extern char SingleLoad_LoadPanelMemory_Str_rb_5[];
extern unsigned char SEQ_SONG_SLOTS[][2048];

int FileIO_CheckRegionSignature(unsigned char r)
{
    int i;
    int ok;
    int n;

    FileIO_SeekAndReadBlock(FileIO_RegionSignatures[r].off, 0);
    ok = 1;
    for (i = 0; i < FileIO_RegionSignatures[r].len; i++) {
        n = FileIO_ReadByte();
        if (n < 0 || (unsigned char)n != FileIO_RegionSignatures[r].sig[i]) {
            ok = 0;
            break;
        }
    }
    FileIO_SeekRead_ExtReturn();
    return ok;
}

int FileIO_ReadHeaderAt4(void)
{
    int ok;
    int n;

    ok = 1;
    FileIO_SeekAndReadBlock(4, 0);
    n = FileIO_ReadByte();
    if (n < 0 || (unsigned char)n != *FileIO_HeaderAt4_ExpectedPtr) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}

int FileIO_ReadHeaderAtF(void)
{
    int ok;
    int n;

    ok = 1;
    FileIO_SeekAndReadBlock(0xf, 0);
    n = FileIO_ReadByte();
    if (n < 0 || (unsigned char)n != 8) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}

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
    if (FileIO_OpenWithMode(hdr, SingleLoad_LoadPanelMemory_Str_rb_2) < 0) return FileIO_ReturnError();
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
            FileIO_ReadBlock((unsigned char *)0xb0000 + p, size);
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
    if (FileIO_OpenWithMode(hdr, SingleLoad_LoadPanelMemory_Str_rb_5) < 0) return FileIO_ReturnError();
    if (FileIO_CheckRegionSignature(4) == 0) {
        FileIO_CloseHandle();
        return -102;
    }
    if (bank < 2) {
        len = 9400;
        o = Math_Multiply32(bank, 9400) + 16;
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
        FileIO_ReadBlock((unsigned char *)0x1e0000 + o2, len);
        r = FileIO_ReturnError();
        TmFlashWrite_ValidateParams(nb, r);
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
    if (FileIO_OpenWithMode(hdr, SingleLoad_LoadPanelMemory_Str_rb) < 0) return FileIO_ReturnError();
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
            FileIO_ReadBlock((unsigned char *)0x1ed350 + o2, 16);
            sz = *(unsigned int *)0x1ed35d;
            sz <<= 3;
            o = Math_Multiply32(bank, sz);
            o += 176;
            o2 = Math_Multiply32(src, sz);
            o2 += 176;
            FileIO_SeekAndReadBlock(o, 0);
            FileIO_ReadBlock((unsigned char *)0x1ed350 + o2, sz);
            r = FileIO_ReturnError();
            PanelMemory_PostBankLoad((unsigned char)src, r);
        }
    }
    FileIO_CloseHandle();
    return r;
}

int WriteFileWithVerify(int idx)
{
    char name1[10];
    char name2[10];
    char hdr1[14];
    char hdr2[14];
    int cur;
    int r;
    long total;
    int i;
    void *e;

    r = 0;
    cur = GetCurrentFileIndex();
    if (cur < 0) return -104;
    total = 0;
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordValid(FileIO_TypeProbeOrder[i]) != 0)
            total += UpdateFileEntry(cur, FileIO_TypeProbeOrder[i]);
    }
    if (FileIO_GetDiskFreeSpace() < total) return -101;
    e = GetFileEntryPtr(idx);
    FileIO_FormatFileIndex(name1, (unsigned char)idx, e);
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordByFile(idx, FileIO_TypeProbeOrder[i]) != 0) {
            FileIO_ReadHeader(hdr1, name1, FileIO_TypeProbeOrder[i]);
            r = FileIO_OpenDefault(hdr1);
            if (r < 0) return r;
        }
    }
    e = GetFileEntryPtr(cur);
    FileIO_FormatFileIndex(name1, (unsigned char)cur, e);
    FileIO_FormatFileIndex(name2, (unsigned char)idx, e);
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordValid(FileIO_TypeProbeOrder[i]) != 0) {
            FileIO_ReadHeader(hdr1, name1, FileIO_TypeProbeOrder[i]);
            FileIO_ReadHeader(hdr2, name2, FileIO_TypeProbeOrder[i]);
            r = FileIO_CompareFiles(hdr2, hdr1);
            if (r < 0) break;
        }
    }
    return r;
}

int ReadDualFileEx(int idx)
{
    char name1[10];
    char name2[10];
    char hdr1[14];
    char hdr2[14];
    int cur;
    void *ea;
    void *eb;
    int i;
    int r;

    r = 0;
    cur = GetCurrentFileIndex();
    if (cur < 0) return -104;
    ea = GetFileEntryPtr(cur);
    eb = GetFileEntryPtr(idx);
    FileIO_FormatFileIndex(name1, (unsigned char)idx, eb);
    FileIO_FormatFileIndex(name2, 20, eb);
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordByFile(idx, FileIO_TypeProbeOrder[i]) != 0) {
            FileIO_ReadHeader(hdr1, name1, FileIO_TypeProbeOrder[i]);
            FileIO_ReadHeader(hdr2, name2, FileIO_TypeProbeOrder[i]);
            r = FileIO_CopyAndOpen(hdr1, hdr2);
            if (r < 0) return r;
        }
    }
    FileIO_FormatFileIndex(name1, (unsigned char)cur, ea);
    FileIO_FormatFileIndex(name2, (unsigned char)idx, ea);
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordValid(FileIO_TypeProbeOrder[i]) != 0) {
            FileIO_ReadHeader(hdr1, name1, FileIO_TypeProbeOrder[i]);
            FileIO_ReadHeader(hdr2, name2, FileIO_TypeProbeOrder[i]);
            r = FileIO_CopyAndOpen(hdr1, hdr2);
            if (r < 0) return r;
        }
    }
    FileIO_FormatFileIndex(name1, 20, eb);
    FileIO_FormatFileIndex(name2, (unsigned char)cur, eb);
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordByFile(idx, FileIO_TypeProbeOrder[i]) != 0) {
            FileIO_ReadHeader(hdr1, name1, FileIO_TypeProbeOrder[i]);
            FileIO_ReadHeader(hdr2, name2, FileIO_TypeProbeOrder[i]);
            r = FileIO_CopyAndOpen(hdr1, hdr2);
            if (r < 0) return r;
        }
    }
    return r;
}

int FileIO_SaveAllRegions(void)
{
    char name[10];
    char hdr[14];
    int r;
    int cur;
    int i;
    void *e;

    r = 0;
    cur = GetCurrentFileIndex();
    if (cur < 0) return -104;
    e = GetFileEntryPtr(cur);
    FileIO_FormatFileIndex(name, (unsigned char)cur, e);
    for (i = 0; i < 8; i++) {
        if (FileIO_CheckRecordValid(SaveAll_RegionSaveRecs[i].type) != 0) {
            FileIO_ReadHeader(hdr, name, SaveAll_RegionSaveRecs[i].type);
            r = FileIO_OpenDefault(hdr);
            if (r < 0) return r;
        }
    }
    FileIO_ReadHeader(hdr, name, 8);
    FileIO_OpenDefault(hdr);
    FileIO_ReadHeader(hdr, name, 9);
    FileIO_OpenDefault(hdr);
    e = FileIO_GetRecordByType();
    FileIO_FormatFileIndex(name, (unsigned char)cur, e);
    for (i = 0; i < 8; i++) {
        if (FileIO_FormatName_Return(SaveAll_RegionSaveRecs[i].type) != 0) {
            r = SaveAll_RegionSaveRecs[i].fn(name);
            if (r < 0) break;
        }
    }
    if (r < 0) {
        for (i = 0; i < 8; i++) {
            if (FileIO_FormatName_Return(SaveAll_RegionSaveRecs[i].type) != 0) {
                FileIO_ReadHeader(hdr, name, SaveAll_RegionSaveRecs[i].type);
                FileIO_OpenDefault(hdr);
            }
        }
    }
    return r;
}
