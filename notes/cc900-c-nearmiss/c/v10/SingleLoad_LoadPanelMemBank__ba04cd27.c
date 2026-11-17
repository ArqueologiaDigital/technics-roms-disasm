/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_F_3m266b.c (2026-11-16-87-p6-r15)
   sha256 ba04cd2758ae3dbed7561438e9f63ed5f676d378170ee3db4767fed362da5ff4 (tar-sha256); compiled at -O3 -XS -Xr */
/* lane_p6 helper F, round 3, module 266 (demo/file_demo_proc.s), form b (form a with: the signature compares
   written table-byte first; WriteFileWithVerify's second entry pointer in its own variable; the save-record
   fields read through a record pointer built as `(char *)base + i * 6`).
   Round 2 (run 72): FileIO_ReadHeaderAtF matched; char-parameter callees prototyped `char` drop V4.23's extz on a
   table byte (as the ROM); separating `e = GetFileEntryPtr(cur)` gave FileIO_SaveAllRegions the ROM's registers
   (file number in IZ, index in QIZ).
   This round: the signature byte compared through a register (char pointer + cast); the record table indexed as
   `(char *)base + i * 6` (the ROM's muls); the three "rb" mode strings under short names (their labels agree in
   31 characters); WriteFileWithVerify's second block with the call nested.
   __near: 16-bit absolute operand; plain: 24-bit (or a ROM label).  One declarator per __near declaration. */

/* cc900-module: FileIO_CheckRegionSignature FileIO_ReadHeaderAt4 */
/* cc900-name: SlStrRb=SingleLoad_LoadPanelMemory_Str_rb */
/* cc900-name: SlStrRb2=SingleLoad_LoadPanelMemory_Str_rb_2 */
/* cc900-name: SlStrRb5=SingleLoad_LoadPanelMemory_Str_rb_5 */

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
typedef int (*SaveFn)(char *);
#define SREC(i)      ((struct SaveRec *)((char *)SaveAll_RegionSaveRecs + (i) * 6))
#define SREC_TYPE(i) (SREC(i)->type)
#define SREC_FN(i)   (SREC(i)->fn)
struct SigRec { char *sig; unsigned int off; unsigned int len; };
extern struct SigRec FileIO_RegionSignatures[];
extern char *FileIO_HeaderAt4_ExpectedPtr;
extern char SlStrRb[];
extern char SlStrRb2[];
extern char SlStrRb5[];
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
        if (n < 0 || (unsigned char)FileIO_RegionSignatures[r].sig[i] != (unsigned char)n) {
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
    if (n < 0 || (unsigned char)*FileIO_HeaderAt4_ExpectedPtr != (unsigned char)n) ok = 0;
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
    if (FileIO_OpenWithMode(hdr, SlStrRb5) < 0) return FileIO_ReturnError();
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
    void *e2;

    r = 0;
    cur = GetCurrentFileIndex();
    if (cur < 0) return -104;
    total = 0;
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordValid(FileIO_TypeProbeOrder[i]) != 0)
            total += UpdateFileEntry(cur, FileIO_TypeProbeOrder[i]);
    }
    if (FileIO_GetDiskFreeSpace() < total) return -101;
    e2 = GetFileEntryPtr(idx);
    FileIO_FormatFileIndex(name1, (unsigned char)idx, e2);
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
        if (FileIO_CheckRecordValid(SREC_TYPE(i)) != 0) {
            FileIO_ReadHeader(hdr, name, SREC_TYPE(i));
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
        if (FileIO_FormatName_Return(SREC_TYPE(i)) != 0) {
            r = SREC_FN(i)(name);
            if (r < 0) break;
        }
    }
    if (r < 0) {
        for (i = 0; i < 8; i++) {
            if (FileIO_FormatName_Return(SREC_TYPE(i)) != 0) {
                FileIO_ReadHeader(hdr, name, SREC_TYPE(i));
                FileIO_OpenDefault(hdr);
            }
        }
    }
    return r;
}
