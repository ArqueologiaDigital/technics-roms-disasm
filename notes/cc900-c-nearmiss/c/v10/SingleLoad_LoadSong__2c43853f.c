/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_4m266a.c (2026-11-16-88-p6-r16)
   sha256 2c43853f1dedfbd12a11e05e21969dd7992b9ef6e52ead7dbb58fafe9b824104 (tar-sha256); compiled at -O3 -Xr
   cc900-name: SlStrRb2=SingleLoad_LoadPanelMemory_Str_rb_2 */
extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern long UpdateFileEntry(int, char);
extern void FileIO_ReadHeader(char *, char *, char);
extern int FileIO_OpenWithMode(char *, char *);
extern int FileIO_ReturnError(void);
extern void FileIO_CloseHandle(void);
extern void FileIO_ReadBlock(void *, unsigned long);
extern int FileIO_CheckRegionSignature(unsigned char);
extern int FileIO_ReadHeaderAt4(void);
extern unsigned long SeqLoad_ProcessDataBlock(int);
extern long SingleLoad_PrepareSongSlot(int);
extern void SingleLoad_FinishSongLoad(int, int);
extern void SetSongSlotValue(unsigned int, int);
extern char SlStrRb2[];
extern unsigned char SEQ_SONG_SLOTS[][2048];
extern unsigned char ram_b0000[];
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
