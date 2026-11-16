/* lane_hd round 13b: hd_r13_songb.c with the macros COPY_STREAMED and COPY_SIZED expanded (V4.23: THC1-Fatal-150,
   "Too large string", for a 2.6 KB #define, run 2026-11-16-74-hd-r13).
 lane_hd round 13, helper h_calr, form b: the same functions as hd_r13_song.c (same names, same cc900-module
   lines), with the alternatives where form a is a guess:
   - Dir_CountEmptySongs: the loop index declared first (which of the two gets IZ, which QIZ);
   - LoadSong_Lsw / SaveSong_Lsw / CopyFdSongToHd_Lsw: info1 declared before info0 (frame order of the two structs);
     the second MemCopy's offset address as a pointer sum, HdStreamBuffer + info0.size (form a: integer sum);
   - TlxPart_Describe / CopyFdSongToHd_Tlx: SwapBytes32 with its prototype (unsigned long) and the result cast to
     int (form a: no prototype, implicit int);
   - CopyFdSongToHd: fname declared before name; CopyFdSongToHd_Pmt / _Sqt-family: the order of n, ret, fname swapped;
   - RoundUpToSector: ldiv through an explicit result pointer and `r.quot * 512` (form a: struct return, `<< 9`);
   - HD_GetSongInfo: an early `return ret` for 0xffff instead of the if body (form a).
   cc900-options: -Xr
   cc900-module: HDAE5000_Song_IsUsed HDAE5000_Song_CheckFreeSpace HDAE5000_Song_PartMask
   cc900-module: HDAE5000_LoadSong_Lsw HDAE5000_LoadSong_Pmt HDAE5000_LoadSong_Sqt HDAE5000_LoadSong_Cmp HDAE5000_LoadSong_Tm
   cc900-module: HDAE5000_LoadSong_Msp HDAE5000_LoadSong_Rcm HDAE5000_LoadSong_Md HDAE5000_LoadSong_Tlx
   cc900-module: HDAE5000_SaveSong_Lsw HDAE5000_SaveSong_Pmt HDAE5000_SaveSong_Sqt HDAE5000_SaveSong_Cmp HDAE5000_SaveSong_Tm
   cc900-module: HDAE5000_SaveSong_Msp HDAE5000_SaveSong_Rcm HDAE5000_SaveSong_Md HDAE5000_SaveSong_Tlx
   cc900-module: HDAE5000_CopyFdSongToHd_Lsw HDAE5000_CopyFdSongToHd_Pmt HDAE5000_CopyFdSongToHd_Sqt HDAE5000_CopyFdSongToHd_Cmp
   cc900-module: HDAE5000_CopyFdSongToHd_Tm HDAE5000_CopyFdSongToHd_Msp HDAE5000_CopyFdSongToHd_Rcm HDAE5000_CopyFdSongToHd_Md
   cc900-module: HDAE5000_CopyFdSongToHd_Tlx
   cc900-module: HDAE5000_DeleteSongPart_Lsw HDAE5000_DeleteSongPart_Pmt HDAE5000_DeleteSongPart_Sqt HDAE5000_DeleteSongPart_Cmp
   cc900-module: HDAE5000_DeleteSongPart_Tm HDAE5000_DeleteSongPart_Msp HDAE5000_DeleteSongPart_Rcm HDAE5000_DeleteSongPart_Md
   cc900-module: HDAE5000_DeleteSongPart_Tlx HDAE5000_DeleteSongParts HDAE5000_Fls_ForgetSong
   cc900-module: HDAE5000_RoundUpToSector HDAE5000_TlxPart_Describe HDAE5000_HD_WriteOpen HDAE5000_HD_WriteClose
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned long addr; unsigned long size; };
struct SongInfo { unsigned int mask; char dirname[16]; char songname[26]; unsigned char has[10]; };
struct RcmCtx { unsigned int state; unsigned int dir; unsigned int song; unsigned int result; };
struct TlxHdr { unsigned char pad[18]; unsigned long trlen; };
typedef struct { long quot; long rem; } ldiv_t;

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern void __cdecl HDAE5000_LDiv(ldiv_t *, long, long);

extern int HDAE5000_HD_ReadFile();
extern int HDAE5000_HD_WriteFile();
extern int HDAE5000_HD_AppendFile();
extern unsigned long HDAE5000_SwapBytes32(unsigned long);
extern int HDAE5000_ATA_SoftReset_Status(void);
extern int HDAE5000_ATA_Standby_Status(void);
extern int HDAE5000_HD_WriteTables_Status(void);
extern void HDAE5000_SeparateOutput_Apply(void);
extern void HDAE5000_Lyrics_ClearBuffer(void);
extern int HDAE5000_RcmStream_Read();
extern int HDAE5000_RcmStream_Write();
extern unsigned int HDAE5000_RcmStream_LastResult(void);
extern long HDAE5000_RcmStream_FreeSpace();

/* the module's other functions (cc900-module), defined elsewhere or below */
extern int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song);
extern int HDAE5000_Song_CheckFreeSpace(unsigned int mask);
extern int HDAE5000_LoadSong_Pmt(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Sqt(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Cmp(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Tm(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Msp(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Md(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Sqt(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Cmp(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Tm(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Msp(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Md(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Lsw(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Pmt(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Sqt(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Cmp(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Tm(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Msp(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Rcm(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Md(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Tlx(unsigned int dir, unsigned int song);
extern void HDAE5000_Fls_ForgetSong(unsigned int dir, unsigned int song);
extern int HDAE5000_HD_WriteClose(void);
int HDAE5000_TlxPart_Describe(int part, struct ResInfo *info);
void HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int keep, int sleep);
unsigned long HDAE5000_RoundUpToSector(unsigned long n);
int HDAE5000_HD_WriteOpen(long *slot);

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern long *HDAE5000_RAM_HdStreamSlot;
extern unsigned char HDAE5000_RAM_HdStreamState;
extern unsigned char HDAE5000_RAM_SeparateOutputMode;
extern unsigned char HDAE5000_RAM_SeparateDrumPart;
extern unsigned char HDAE5000_RAM_SeparateBassPart;
extern struct RcmCtx HDAE5000_RAM_RcmStreamState;
extern unsigned int HDAE5000_RAM_RcmStreamDir;
extern unsigned int HDAE5000_RAM_RcmStreamSong;
extern struct RcmCtx HDAE5000_RcmStream_InitialState;
extern unsigned char HDAE5000_RAM_LyricBuffer[0x5000];
extern unsigned long HDAE5000_RAM_LyricFileLength;

/* the "rb" fopen modes, HDAE5000_CopyFdSongToHd_Str_rb and HDAE5000_CopyFdSongToHd_<Part>_Str_rb */
extern char HDAE5000_CopyFdSongToHd_Str_rb[];
extern char ram_2f8f0e[], ram_2f8f18[], ram_2f8f22[], ram_2f8f2c[], ram_2f8f34[];
extern char ram_2f8f3e[], ram_2f8f48[], ram_2f8f50[], ram_2f8f5a[];
/* the extensions, pushed as 32-bit constants: HDAE5000_CopyFdSongToHd_Str_TTX, ..._<Part>_Str_<PART> */
#define STR_TTX ((char *)0x2f8efeL)
#define STR_LSW ((char *)0x2f8f08L)
#define STR_PMT ((char *)0x2f8f12L)
#define STR_SQT ((char *)0x2f8f1cL)
#define STR_CMP ((char *)0x2f8f26L)
#define STR_TM  ((char *)0x2f8f30L)
#define STR_MSP ((char *)0x2f8f38L)
#define STR_RCM ((char *)0x2f8f42L)
#define STR_MD  ((char *)0x2f8f4cL)
#define STR_TLX ((char *)0x2f8f54L)

#define TLX_TRLEN (*(unsigned long *)&HDAE5000_RAM_LyricBuffer[18])

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define HAS(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))

unsigned int HDAE5000_Dir_CountEmptySongs(unsigned int dir)
{
    unsigned int song;
    unsigned int n;

    n = 0;
    for (song = 0; song < 16; song++)
        if (HDAE5000_Song_IsUsed(dir, song) == -1)
            n++;
    return n;
}

unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song)
{
    unsigned int mask;

    mask = 0;
    if (HDAE5000_Song_IsUsed(dir, song) != -1) {
        if (SLOT(0, dir, song) != -1L) mask |= 0x001;
        if (SLOT(1, dir, song) != -1L) mask |= 0x002;
        if (SLOT(2, dir, song) != -1L) mask |= 0x004;
        if (SLOT(3, dir, song) != -1L) mask |= 0x008;
        if (SLOT(4, dir, song) != -1L) mask |= 0x010;
        if (SLOT(5, dir, song) != -1L) mask |= 0x020;
        if (SLOT(6, dir, song) != -1L) mask |= 0x040;
        if (SLOT(7, dir, song) != -1L) mask |= 0x080;
        if (SLOT(8, dir, song) != -1L) mask |= 0x100;
    } else
        mask = 0xffff;
    return mask;
}

int HDAE5000_LoadSong_Lsw(unsigned int dir, unsigned int song);
int HDAE5000_LoadSong_Rcm(unsigned int dir, unsigned int song);
int HDAE5000_LoadSong_Tlx(unsigned int dir, unsigned int song);

/* the stacked words: keep = 1 leaves the drive spinning, sleep = 1 puts the main task to sleep (retd 4) */
int HDAE5000_LoadSong(unsigned int dir, unsigned int song, unsigned int mask, int keep, int sleep)
{
    int ret;

    CALLV(HAMA->PlayHalt)(1);
    if (sleep == 1)
        CALLV(ROOT->SleepMainTask)();
    HDAE5000_ATA_SoftReset_Status();
    if (mask & 0x001)
        ret = HDAE5000_LoadSong_Lsw(dir, song);
    if (ret != -1 && (mask & 0x002))
        ret = HDAE5000_LoadSong_Pmt(dir, song);
    if (ret != -1 && (mask & 0x004))
        ret = HDAE5000_LoadSong_Sqt(dir, song);
    if (ret != -1 && (mask & 0x008))
        ret = HDAE5000_LoadSong_Cmp(dir, song);
    if (ret != -1 && (mask & 0x010))
        ret = HDAE5000_LoadSong_Tm(dir, song);
    if (ret != -1 && (mask & 0x020))
        ret = HDAE5000_LoadSong_Msp(dir, song);
    if (ret != -1 && (mask & 0x040))
        ret = HDAE5000_LoadSong_Rcm(dir, song);
    if (ret != -1 && (mask & 0x080))
        ret = HDAE5000_LoadSong_Md(dir, song);
    if (ret != -1 && (mask & 0x100))
        ret = HDAE5000_LoadSong_Tlx(dir, song);
    if (keep != 1)
        HDAE5000_ATA_Standby_Status();
    if (sleep == 1)
        CALLV(ROOT->WakeUpMainTask)();
    CALLV(HAMA->PlayStandBy)();
    CALLV(HAMA->EditSwRefresh)();
    return ret;
}

int HDAE5000_LoadSong_Lsw(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info1;
    struct ResInfo info0;
    unsigned long size;

    if (SLOT(0, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(0, (char *)&info0);
        CALLV(HAMA->GetResouceInfo)(1, (char *)&info1);
        size = HDAE5000_RoundUpToSector(info1.size + info0.size);
        CALLV(HAMA->PreLswLoad)();
        ret = HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, size, &SLOT(0, dir, song));
        HDAE5000_MemCopy((void *)info0.addr, HDAE5000_RAM_HdStreamBuffer, (unsigned int)info0.size);
        HDAE5000_MemCopy((void *)info1.addr, HDAE5000_RAM_HdStreamBuffer + info0.size,
                         (unsigned int)info1.size);
        HDAE5000_RAM_SeparateOutputMode = HDAE5000_RAM_HdStreamBuffer[info1.size + info0.size];
        HDAE5000_RAM_SeparateDrumPart = HDAE5000_RAM_HdStreamBuffer[info1.size + info0.size + 1];
        HDAE5000_RAM_SeparateBassPart = HDAE5000_RAM_HdStreamBuffer[info1.size + info0.size + 2];
        HDAE5000_SeparateOutput_Apply();
        CALLV(HAMA->PostLswLoad)(ret);
    }
    return ret;
}

int HDAE5000_LoadSong_Rcm(unsigned int dir, unsigned int song)
{
    if (SLOT(6, dir, song) != -1L) {
        HDAE5000_RAM_RcmStreamState = HDAE5000_RcmStream_InitialState;
        HDAE5000_RAM_RcmStreamDir = dir;
        HDAE5000_RAM_RcmStreamSong = song;
        CALLV(HAMA->rcm_ld_XAPR_j)((long)HDAE5000_RcmStream_Read, (long)HDAE5000_RcmStream_LastResult);
    }
    return 0;
}

int HDAE5000_LoadSong_Tlx(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;

    if (SLOT(8, dir, song) != -1L) {
        HDAE5000_Lyrics_ClearBuffer();
        HDAE5000_TlxPart_Describe(10, &info);
        if ((ret = HDAE5000_HD_ReadFile(info.addr, 0x16L, &SLOT(8, dir, song))) != -1) {
            HDAE5000_TlxPart_Describe(10, &info);
            ret = HDAE5000_HD_ReadFile(info.addr, info.size, &SLOT(8, dir, song));
        }
    }
    return ret;
}

int HDAE5000_SaveSong_Lsw(unsigned int dir, unsigned int song);
int HDAE5000_SaveSong_Pmt(unsigned int dir, unsigned int song);
int HDAE5000_SaveSong_Rcm(unsigned int dir, unsigned int song);
int HDAE5000_SaveSong_Tlx(unsigned int dir, unsigned int song);

/* stacked words (retd 6): keep, sleep, mask */
int HDAE5000_SaveSong(unsigned int dir, unsigned int song, char *name, int keep, int sleep, unsigned int mask)
{
    int ret = 0;

    if (mask == 0)
        return ret;
    if (HDAE5000_Song_CheckFreeSpace(mask) != -1) {
        CALLV(HAMA->PlayHalt)(1);
        if (sleep == 1)
            CALLV(ROOT->SleepMainTask)();
        HDAE5000_ATA_SoftReset_Status();
        if (mask & 0x001) {
            if ((ret = HDAE5000_SaveSong_Lsw(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Lsw(dir, song);
        } else
            HDAE5000_DeleteSongPart_Lsw(dir, song);
        if (ret != -1 && (mask & 0x002)) {
            if ((ret = HDAE5000_SaveSong_Pmt(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Pmt(dir, song);
        } else
            HDAE5000_DeleteSongPart_Pmt(dir, song);
        if (ret != -1 && (mask & 0x004)) {
            if ((ret = HDAE5000_SaveSong_Sqt(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Sqt(dir, song);
        } else
            HDAE5000_DeleteSongPart_Sqt(dir, song);
        if (ret != -1 && (mask & 0x008)) {
            if ((ret = HDAE5000_SaveSong_Cmp(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Cmp(dir, song);
        } else
            HDAE5000_DeleteSongPart_Cmp(dir, song);
        if (ret != -1 && (mask & 0x010)) {
            if ((ret = HDAE5000_SaveSong_Tm(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Tm(dir, song);
        } else
            HDAE5000_DeleteSongPart_Tm(dir, song);
        if (ret != -1 && (mask & 0x020)) {
            if ((ret = HDAE5000_SaveSong_Msp(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Msp(dir, song);
        } else
            HDAE5000_DeleteSongPart_Msp(dir, song);
        if (ret != -1 && (mask & 0x040)) {
            if ((ret = HDAE5000_SaveSong_Rcm(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Rcm(dir, song);
        } else
            HDAE5000_DeleteSongPart_Rcm(dir, song);
        if (ret != -1 && (mask & 0x080)) {
            if ((ret = HDAE5000_SaveSong_Md(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Md(dir, song);
        } else
            HDAE5000_DeleteSongPart_Md(dir, song);
        if (ret != -1 && (mask & 0x100)) {
            if ((ret = HDAE5000_SaveSong_Tlx(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Tlx(dir, song);
        } else
            HDAE5000_DeleteSongPart_Tlx(dir, song);
        if (ret != -1) {
            HDAE5000_StrNCpy(&HDAE5000_RAM_DirNames[SONG_OFS(dir, song)], name, 26);
            HDAE5000_HD_WriteTables_Status();
        } else
            HDAE5000_DeleteSongParts(dir, song, 0x1ff, keep, 0);
        if (keep != 1)
            HDAE5000_ATA_Standby_Status();
        if (sleep == 1)
            CALLV(ROOT->WakeUpMainTask)();
        CALLV(HAMA->EditSwRefresh)();
        CALLV(HAMA->PlayStandBy)();
    } else
        ret = -1;
    return ret;
}

int HDAE5000_SaveSong_Lsw(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info1;
    struct ResInfo info0;
    unsigned long size;

    CALLV(HAMA->GetResouceInfo)(0, (char *)&info0);
    CALLV(HAMA->GetResouceInfo)(1, (char *)&info1);
    size = HDAE5000_RoundUpToSector(info1.size + info0.size);
    CALLV(HAMA->PreLswSave)();
    HDAE5000_MemFill(HDAE5000_RAM_HdStreamBuffer, 0, (unsigned int)size);
    HDAE5000_MemCopy(HDAE5000_RAM_HdStreamBuffer, (void *)info0.addr, (unsigned int)info0.size);
    HDAE5000_MemCopy(HDAE5000_RAM_HdStreamBuffer + info0.size, (void *)info1.addr,
                     (unsigned int)info1.size);
    HDAE5000_RAM_HdStreamBuffer[info1.size + info0.size] = HDAE5000_RAM_SeparateOutputMode;
    HDAE5000_RAM_HdStreamBuffer[info1.size + info0.size + 1] = HDAE5000_RAM_SeparateDrumPart;
    HDAE5000_RAM_HdStreamBuffer[info1.size + info0.size + 2] = HDAE5000_RAM_SeparateBassPart;
    if ((ret = HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, size, &SLOT(0, dir, song))) != -1)
        HAS(0, dir, song) = 1;
    CALLV(HAMA->PostLswSave)(ret);
    return ret;
}

int HDAE5000_SaveSong_Pmt(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info;

    CALLV(HAMA->GetResouceInfo)(2, (char *)&info);
    info.size = HDAE5000_RoundUpToSector(info.size);
    CALLV(HAMA->PrePmSave)();
    if ((ret = HDAE5000_HD_WriteFile(info.addr, info.size, &SLOT(1, dir, song))) != -1)
        HAS(1, dir, song) = 1;
    CALLV(HAMA->PostPmSave)(ret);
    return ret;
}

int HDAE5000_SaveSong_Rcm(unsigned int dir, unsigned int song)
{
    int ret = 0;

    HDAE5000_RAM_RcmStreamState = HDAE5000_RcmStream_InitialState;
    HDAE5000_RAM_RcmStreamDir = dir;
    HDAE5000_RAM_RcmStreamSong = song;
    if ((ret = HDAE5000_HD_WriteOpen(&SLOT(6, HDAE5000_RAM_RcmStreamDir, HDAE5000_RAM_RcmStreamSong))) != -1) {
        CALLV(HAMA->rcm_sv_XAPR_j)((long)HDAE5000_RcmStream_FreeSpace, (long)HDAE5000_RcmStream_Write,
                                   (long)HDAE5000_RcmStream_LastResult);
        ret = HDAE5000_HD_WriteClose();
    }
    return ret;
}

int HDAE5000_SaveSong_Tlx(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info;

    HDAE5000_TlxPart_Describe(10, &info);
    info.size = HDAE5000_RoundUpToSector(info.size);
    if ((ret = HDAE5000_HD_WriteFile(info.addr, info.size, &SLOT(8, dir, song))) != -1)
        HAS(8, dir, song) = 1;
    return ret;
}

/* the TLX part's extent; returns its first argument */
int HDAE5000_TlxPart_Describe(int part, struct ResInfo *info)
{
    info->addr = (unsigned long)HDAE5000_RAM_LyricBuffer;
    HDAE5000_RAM_LyricFileLength = info->size = (int)HDAE5000_SwapBytes32(TLX_TRLEN) + 0x16;
    return part;
}

int HDAE5000_CopyFdSongToHd_Lsw(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Pmt(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Sqt(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Cmp(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Tm(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Msp(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Rcm(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Md(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Tlx(unsigned int dir, unsigned int song, char *fdname);

/* XDE = the floppy song's 8-character file name; stacked words (retd 6): keep, sleep, mask */
int HDAE5000_CopyFdSongToHd(unsigned int dir, unsigned int song, char *fdname, int keep, int sleep,
                            unsigned int mask)
{
    int ret = 0;
    char fname[14];
    char name[27];

    if (HDAE5000_Song_CheckFreeSpace(mask) != -1) {
        CALLV(HAMA->PlayHalt)(1);
        if (sleep == 1)
            CALLV(ROOT->SleepMainTask)();
        HDAE5000_ATA_SoftReset_Status();
        if (mask & 0x001) {
            if ((ret = HDAE5000_CopyFdSongToHd_Lsw(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Lsw(dir, song);
        }
        if (ret != -1 && (mask & 0x002)) {
            if ((ret = HDAE5000_CopyFdSongToHd_Pmt(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Pmt(dir, song);
        }
        if (ret != -1 && (mask & 0x004)) {
            if ((ret = HDAE5000_CopyFdSongToHd_Sqt(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Sqt(dir, song);
        }
        if (ret != -1 && (mask & 0x008)) {
            if ((ret = HDAE5000_CopyFdSongToHd_Cmp(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Cmp(dir, song);
        }
        if (ret != -1 && (mask & 0x010)) {
            if ((ret = HDAE5000_CopyFdSongToHd_Tm(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Tm(dir, song);
        }
        if (ret != -1 && (mask & 0x020)) {
            if ((ret = HDAE5000_CopyFdSongToHd_Msp(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Msp(dir, song);
        }
        if (ret != -1 && (mask & 0x040)) {
            if ((ret = HDAE5000_CopyFdSongToHd_Rcm(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Rcm(dir, song);
        }
        if (ret != -1 && (mask & 0x080)) {
            if ((ret = HDAE5000_CopyFdSongToHd_Md(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Md(dir, song);
        }
        if (ret != -1 && (mask & 0x100)) {
            if ((ret = HDAE5000_CopyFdSongToHd_Tlx(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Tlx(dir, song);
        }
        if (ret != -1) {
            HDAE5000_MemFill(name, ' ', 26);
            name[26] = 0;
            HDAE5000_MemCopy(fname, fdname, 8);
            HDAE5000_StrCpy(fname + 8, STR_TTX);
            if (CALLR(int, HAMA->fopen_ext)(fname, HDAE5000_CopyFdSongToHd_Str_rb) >= 0)
                CALLV(HAMA->fread_ext)(name, 26L);
            else
                HDAE5000_MemCopy(name, fdname + 2, 6);
            CALLV(HAMA->fclose_ext)();
            HDAE5000_StrNCpy(&HDAE5000_RAM_DirNames[SONG_OFS(dir, song)], name, 26);
            HDAE5000_HD_WriteTables_Status();
        } else
            HDAE5000_DeleteSongParts(dir, song, 0x1ff, keep, 0);
        if (keep != 1)
            HDAE5000_ATA_Standby_Status();
        if (sleep == 1)
            CALLV(ROOT->WakeUpMainTask)();
        CALLV(HAMA->PlayStandBy)();
        CALLV(HAMA->EditSwRefresh)();
    } else
        ret = -1;
    return ret;
}

int HDAE5000_CopyFdSongToHd_Lsw(unsigned int dir, unsigned int song, char *fdname)
{
    int ret = 0;
    struct ResInfo info1;
    struct ResInfo info0;
    char fname[14];
    unsigned long size;

    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_LSW);
    CALLV(HAMA->GetResouceInfo)(0, (char *)&info0);
    CALLV(HAMA->GetResouceInfo)(1, (char *)&info1);
    size = HDAE5000_RoundUpToSector(info1.size + info0.size);
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2f8f0e) >= 0) {
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, size);
        HDAE5000_RAM_HdStreamBuffer[info1.size + info0.size] = 0;
        HDAE5000_RAM_HdStreamBuffer[info1.size + info0.size + 1] = 0x10;
        HDAE5000_RAM_HdStreamBuffer[info1.size + info0.size + 2] = 0;
        ret = HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, size, &SLOT(0, dir, song));
        HAS(0, dir, song) = 1;
        CALLV(HAMA->fclose_ext)();
    } else
        ret = -1;
    return ret;
}

/* PMT: the first write's result is kept (ret); the 0x8000-byte reads that follow are appended */
int HDAE5000_CopyFdSongToHd_Pmt(unsigned int dir, unsigned int song, char *fdname)
{
    long n;
    int ret = 0;
    char fname[14];

    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_PMT);
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2f8f18) < 0)
        return -1;
    n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x8000L);
    if ((ret = HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, HDAE5000_RoundUpToSector(n),
                                     &SLOT(1, dir, song))) == -1)
        return -1;
    while (n == 0x8000L) {
        n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x8000L);
        if (n > 0) {
            if ((ret = HDAE5000_HD_AppendFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                              HDAE5000_RoundUpToSector(n), &SLOT(1, dir, song))) == -1)
                break;
        }
    }
    HAS(1, dir, song) = 1;
    CALLV(HAMA->fclose_ext)();
    return ret;
}

/* SQT, CMP, RCM: as PMT, but the first write's result is only tested */

int HDAE5000_CopyFdSongToHd_Sqt(unsigned int dir, unsigned int song, char *fdname) { 
    char fname[14];
    long n;
    int ret = 0;
    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_SQT);
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2f8f22) < 0)
        return -1;
    n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x8000L);
    if (HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, HDAE5000_RoundUpToSector(n),
                              &SLOT(2, dir, song)) == -1)
        return -1;
    while (n == 0x8000L) {
        n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x8000L);
        if (n > 0) {
            if ((ret = HDAE5000_HD_AppendFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                              HDAE5000_RoundUpToSector(n), &SLOT(2, dir, song))) == -1)
                break;
        }
    }
    HAS(2, dir, song) = 1;
    CALLV(HAMA->fclose_ext)();
    return ret;
 }
int HDAE5000_CopyFdSongToHd_Cmp(unsigned int dir, unsigned int song, char *fdname) { 
    char fname[14];
    long n;
    int ret = 0;
    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_CMP);
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2f8f2c) < 0)
        return -1;
    n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x8000L);
    if (HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, HDAE5000_RoundUpToSector(n),
                              &SLOT(3, dir, song)) == -1)
        return -1;
    while (n == 0x8000L) {
        n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x8000L);
        if (n > 0) {
            if ((ret = HDAE5000_HD_AppendFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                              HDAE5000_RoundUpToSector(n), &SLOT(3, dir, song))) == -1)
                break;
        }
    }
    HAS(3, dir, song) = 1;
    CALLV(HAMA->fclose_ext)();
    return ret;
 }

/* TM, MSP, MD: one read of the resource's size (TM's fixed at 0x72aa) */

int HDAE5000_CopyFdSongToHd_Tm(unsigned int dir, unsigned int song, char *fdname)
{
    
    int ret = 0;
    struct ResInfo info;
    char fname[14];
    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_TM);
    CALLV(HAMA->GetResouceInfo)(6, (char *)&info);
    info.size = 0x72aaL;
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2f8f34) >= 0) {
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, info.size);
        ret = HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                    HDAE5000_RoundUpToSector(info.size), &SLOT(4, dir, song));
        HAS(4, dir, song) = 1;
        CALLV(HAMA->fclose_ext)();
    } else
        ret = -1;
    return ret;

}

int HDAE5000_CopyFdSongToHd_Msp(unsigned int dir, unsigned int song, char *fdname)
{
    
    int ret = 0;
    struct ResInfo info;
    char fname[14];
    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_MSP);
    CALLV(HAMA->GetResouceInfo)(7, (char *)&info);
    ;
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2f8f3e) >= 0) {
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, info.size);
        ret = HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                    HDAE5000_RoundUpToSector(info.size), &SLOT(5, dir, song));
        HAS(5, dir, song) = 1;
        CALLV(HAMA->fclose_ext)();
    } else
        ret = -1;
    return ret;

}

int HDAE5000_CopyFdSongToHd_Rcm(unsigned int dir, unsigned int song, char *fdname) { 
    char fname[14];
    long n;
    int ret = 0;
    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_RCM);
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2f8f48) < 0)
        return -1;
    n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x8000L);
    if (HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, HDAE5000_RoundUpToSector(n),
                              &SLOT(6, dir, song)) == -1)
        return -1;
    while (n == 0x8000L) {
        n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x8000L);
        if (n > 0) {
            if ((ret = HDAE5000_HD_AppendFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                              HDAE5000_RoundUpToSector(n), &SLOT(6, dir, song))) == -1)
                break;
        }
    }
    HAS(6, dir, song) = 1;
    CALLV(HAMA->fclose_ext)();
    return ret;
 }

int HDAE5000_CopyFdSongToHd_Md(unsigned int dir, unsigned int song, char *fdname)
{
    
    int ret = 0;
    struct ResInfo info;
    char fname[14];
    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_MD);
    CALLV(HAMA->GetResouceInfo)(9, (char *)&info);
    ;
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2f8f50) >= 0) {
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, info.size);
        ret = HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                    HDAE5000_RoundUpToSector(info.size), &SLOT(7, dir, song));
        HAS(7, dir, song) = 1;
        CALLV(HAMA->fclose_ext)();
    } else
        ret = -1;
    return ret;

}

/* TLX: the 22-byte TLhd header first (after clearing the buffer), then the TLtr chunk behind it */
int HDAE5000_CopyFdSongToHd_Tlx(unsigned int dir, unsigned int song, char *fdname)
{
    int ret = 0;
    struct ResInfo info;
    char fname[14];
    long len;

    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_TLX);
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2f8f5a) >= 0) {
        HDAE5000_MemFill(HDAE5000_RAM_HdStreamBuffer, 0, 0x8000);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x16L);
        len = (int)HDAE5000_SwapBytes32(((struct TlxHdr *)HDAE5000_RAM_HdStreamBuffer)->trlen);
        info.size = HDAE5000_RoundUpToSector(len + 0x16);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer + 0x16, len);
        ret = HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, info.size, &SLOT(8, dir, song));
        HAS(8, dir, song) = 1;
        CALLV(HAMA->fclose_ext)();
    } else
        ret = -1;
    return ret;
}

/* WA = directory, BC = sleep, DE = keep */
void HDAE5000_DeleteDirectory(unsigned int dir, int sleep, int keep)
{
    unsigned int song;

    CALLV(HAMA->PlayHalt)(1);
    if (sleep == 1)
        CALLV(ROOT->SleepMainTask)();
    HDAE5000_ATA_SoftReset_Status();
    for (song = 0; song < 16; song++) {
        if (HDAE5000_Song_IsUsed(dir, song) != -1) {
            HDAE5000_DeleteSongPart_Lsw(dir, song);
            HDAE5000_DeleteSongPart_Pmt(dir, song);
            HDAE5000_DeleteSongPart_Sqt(dir, song);
            HDAE5000_DeleteSongPart_Cmp(dir, song);
            HDAE5000_DeleteSongPart_Tm(dir, song);
            HDAE5000_DeleteSongPart_Msp(dir, song);
            HDAE5000_DeleteSongPart_Rcm(dir, song);
            HDAE5000_DeleteSongPart_Md(dir, song);
            HDAE5000_DeleteSongPart_Tlx(dir, song);
            HDAE5000_Fls_ForgetSong(dir, song);
        }
        HDAE5000_MemFill(&HDAE5000_RAM_DirNames[SONG_OFS(dir, song)], ' ', 26);
    }
    HDAE5000_MemFill(&HDAE5000_RAM_DirNames[(unsigned long)dir * 16], ' ', 16);
    HDAE5000_HD_WriteTables_Status();
    if (keep != 1)
        HDAE5000_ATA_Standby_Status();
    if (sleep == 1)
        CALLV(ROOT->WakeUpMainTask)();
    CALLV(HAMA->PlayStandBy)();
    CALLV(HAMA->EditSwRefresh)();
}

/* stacked words (retd 4): keep, sleep */
void HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int keep, int sleep)
{
    if (mask != 0) {
        CALLV(HAMA->PlayHalt)(1);
        if (sleep == 1)
            CALLV(ROOT->SleepMainTask)();
        HDAE5000_ATA_SoftReset_Status();
        if (mask & 0x001)
            HDAE5000_DeleteSongPart_Lsw(dir, song);
        if (mask & 0x002)
            HDAE5000_DeleteSongPart_Pmt(dir, song);
        if (mask & 0x004)
            HDAE5000_DeleteSongPart_Sqt(dir, song);
        if (mask & 0x008)
            HDAE5000_DeleteSongPart_Cmp(dir, song);
        if (mask & 0x010)
            HDAE5000_DeleteSongPart_Tm(dir, song);
        if (mask & 0x020)
            HDAE5000_DeleteSongPart_Msp(dir, song);
        if (mask & 0x040)
            HDAE5000_DeleteSongPart_Rcm(dir, song);
        if (mask & 0x080)
            HDAE5000_DeleteSongPart_Md(dir, song);
        if (mask & 0x100)
            HDAE5000_DeleteSongPart_Tlx(dir, song);
        if (HDAE5000_Song_IsUsed(dir, song) == -1) {
            HDAE5000_MemFill(&HDAE5000_RAM_DirNames[SONG_OFS(dir, song)], ' ', 26);
            HDAE5000_Fls_ForgetSong(dir, song);
        }
        HDAE5000_HD_WriteTables_Status();
        if (keep != 1)
            HDAE5000_ATA_Standby_Status();
        if (sleep == 1)
            CALLV(ROOT->WakeUpMainTask)();
        CALLV(HAMA->PlayStandBy)();
        CALLV(HAMA->EditSwRefresh)();
    }
}

/* bytes rounded up to whole 512-byte sectors, 0 counting as one sector */
unsigned long HDAE5000_RoundUpToSector(unsigned long n)
{
    unsigned long ret;
    ldiv_t r;

    ret = n;
    if (n != 0) {
        HDAE5000_LDiv(&r, n, 512);
        if (r.rem != 0)
            ret = r.quot * 512 + 0x200;
    } else
        ret = 0x200;
    return ret;
}

/* XDE = the 54-byte record to fill: mask, directory name, song name, part bytes; HL = 0, or 0xffff (no song) */
int HDAE5000_HD_GetSongInfo(unsigned int dir, unsigned int song, struct SongInfo *info)
{
    unsigned int ret;

    if ((ret = HDAE5000_Song_PartMask(dir, song)) == 0xffff)
        return ret;
    info->mask = ret;
    HDAE5000_MemCopy(info->dirname, &HDAE5000_RAM_DirNames[(unsigned long)dir * 16], 16);
    HDAE5000_MemCopy(info->songname, &HDAE5000_RAM_DirNames[SONG_OFS(dir, song)], 26);
    HDAE5000_MemCopy(info->has, &HAS(0, dir, song), 10);
    return 0;
}

int HDAE5000_HD_WriteOpen(long *slot)
{
    if (HDAE5000_RAM_HdStreamState != 0) {
        HDAE5000_RAM_HdStreamState = 0;
        return -1;
    }
    HDAE5000_RAM_HdStreamFill = HDAE5000_RAM_HdStreamBuffer;
    HDAE5000_RAM_HdStreamSlot = slot;
    HDAE5000_RAM_HdStreamState = 1;
    return 0;
}
