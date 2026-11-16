/* hdae5000_v1_10i: the functions of hdae5000/cc900-staged/hdae5000_song_module.c that V4.23 reproduces unchanged in HD-AE5000 v1.10i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_song_module.c.
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
extern ldiv_t __cdecl HDAE5000_LDiv(long, long);

extern int HDAE5000_HD_ReadFile();
extern int HDAE5000_HD_WriteFile();
extern int HDAE5000_HD_AppendFile();
extern int HDAE5000_SwapBytes32();
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
int HDAE5000_TlxPart_Describe();
void HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int sleep, int keep);
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
/* the extensions, pushed as pushw hi16 / lo16 (an extern array; a numeric constant gives ld xwa,imm / push xwa):
   HDAE5000_CopyFdSongToHd_Str_TTX (0x2f8efe), HDAE5000_CopyFdSongToHd_<Part>_Str_<PART>, under ram_<hex> names
   because the part labels share their first 31 characters with _Str_rb */
extern char ram_2f8efe[], ram_2f8f08[], ram_2f8f12[], ram_2f8f1c[], ram_2f8f26[];
extern char ram_2f8f30[], ram_2f8f38[], ram_2f8f42[], ram_2f8f4c[], ram_2f8f54[];
#define STR_TTX ram_2f8efe
#define STR_LSW ram_2f8f08
#define STR_PMT ram_2f8f12
#define STR_SQT ram_2f8f1c
#define STR_CMP ram_2f8f26
#define STR_TM  ram_2f8f30
#define STR_MSP ram_2f8f38
#define STR_RCM ram_2f8f42
#define STR_MD  ram_2f8f4c
#define STR_TLX ram_2f8f54

#define TLX_TRLEN (*(unsigned long *)&HDAE5000_RAM_LyricBuffer[18])

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define HAS(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))

int HDAE5000_LoadSong_Lsw(unsigned int dir, unsigned int song);
int HDAE5000_LoadSong_Rcm(unsigned int dir, unsigned int song);
int HDAE5000_LoadSong_Tlx(unsigned int dir, unsigned int song);

/* the stacked words (retd 4; V4.23 puts the last parameter lowest): keep = 1 leaves the drive spinning (xsp+12),
   sleep = 1 puts the main task to sleep (xsp+14) */

int HDAE5000_LoadSong_Lsw(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info0;
    struct ResInfo info1;
    unsigned long size;

    if (SLOT(0, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(0, (char *)&info0);
        CALLV(HAMA->GetResouceInfo)(1, (char *)&info1);
        size = HDAE5000_RoundUpToSector(info0.size + info1.size);
        CALLV(HAMA->PreLswLoad)();
        ret = HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, size, &SLOT(0, dir, song));
        HDAE5000_MemCopy((void *)info0.addr, HDAE5000_RAM_HdStreamBuffer, (unsigned int)info0.size);
        HDAE5000_MemCopy((void *)info1.addr, (void *)((unsigned long)HDAE5000_RAM_HdStreamBuffer + info0.size),
                         (unsigned int)info1.size);
        HDAE5000_RAM_SeparateOutputMode = HDAE5000_RAM_HdStreamBuffer[info0.size + info1.size];
        HDAE5000_RAM_SeparateDrumPart = HDAE5000_RAM_HdStreamBuffer[info0.size + info1.size + 1];
        HDAE5000_RAM_SeparateBassPart = HDAE5000_RAM_HdStreamBuffer[info0.size + info1.size + 2];
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

int HDAE5000_SaveSong_Lsw(unsigned int dir, unsigned int song);
int HDAE5000_SaveSong_Pmt(unsigned int dir, unsigned int song);
int HDAE5000_SaveSong_Rcm(unsigned int dir, unsigned int song);
int HDAE5000_SaveSong_Tlx(unsigned int dir, unsigned int song);

/* stacked words (retd 6), lowest first: keep (xsp+18), sleep, mask (xsp+22) */

int HDAE5000_SaveSong_Lsw(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info0;
    struct ResInfo info1;
    unsigned long size;

    CALLV(HAMA->GetResouceInfo)(0, (char *)&info0);
    CALLV(HAMA->GetResouceInfo)(1, (char *)&info1);
    size = HDAE5000_RoundUpToSector(info0.size + info1.size);
    CALLV(HAMA->PreLswSave)();
    HDAE5000_MemFill(HDAE5000_RAM_HdStreamBuffer, 0, (unsigned int)size);
    HDAE5000_MemCopy(HDAE5000_RAM_HdStreamBuffer, (void *)info0.addr, (unsigned int)info0.size);
    HDAE5000_MemCopy((void *)((unsigned long)HDAE5000_RAM_HdStreamBuffer + info0.size), (void *)info1.addr,
                     (unsigned int)info1.size);
    HDAE5000_RAM_HdStreamBuffer[info0.size + info1.size]= HDAE5000_RAM_SeparateOutputMode;
    HDAE5000_RAM_HdStreamBuffer[info0.size + info1.size + 1]= HDAE5000_RAM_SeparateDrumPart;
    HDAE5000_RAM_HdStreamBuffer[info0.size + info1.size + 2]= HDAE5000_RAM_SeparateBassPart;
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

/* the TLX part's extent; returns its first argument */

int HDAE5000_CopyFdSongToHd_Lsw(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Pmt(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Sqt(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Cmp(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Tm(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Msp(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Rcm(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Md(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Tlx(unsigned int dir, unsigned int song, char *fdname);

/* XDE = the floppy song's 8-character file name; stacked words (retd 6), lowest first: keep, sleep, mask (xsp+64) */

/* PMT: the first write's result is kept (ret); the 0x8000-byte reads that follow are appended */

/* SQT, CMP, RCM: as PMT, but the first write's result is only tested */

/* TM, MSP, MD: one read of the resource's size (TM's fixed at 0x72aa) */

/* TLX: the 22-byte TLhd header first (after clearing the buffer), then the TLtr chunk behind it */

/* WA = directory, BC = sleep, DE = keep */

/* stacked words (retd 4), lowest first: keep (xsp+12), sleep (xsp+14) */

/* bytes rounded up to whole 512-byte sectors, 0 counting as one sector */
unsigned long HDAE5000_RoundUpToSector(unsigned long n)
{
    unsigned long ret;
    ldiv_t r;

    ret = n;
    if (n != 0) {
        r = HDAE5000_LDiv(n, 512);
        if (r.rem != 0)
            ret = (r.quot << 9) + 0x200;
    } else
        ret = 0x200;
    return ret;
}

/* XDE = the 54-byte record to fill: mask, directory name, song name, part bytes; HL = 0, or 0xffff (no song) */
int HDAE5000_HD_GetSongInfo(unsigned int dir, unsigned int song, struct SongInfo *info)
{
    unsigned int ret;

    if ((ret = HDAE5000_Song_PartMask(dir, song)) != 0xffff) {
        info->mask = ret;
        HDAE5000_MemCopy(info->dirname, &HDAE5000_RAM_DirNames[(unsigned long)dir * 16], 16);
        HDAE5000_MemCopy(info->songname, &HDAE5000_RAM_DirNames[SONG_OFS(dir, song)], 26);
        HDAE5000_MemCopy(info->has, &HAS(0, dir, song), 10);
        ret = 0;
    }
    return ret;
}

/* one return: the ROM's -1 path jumps (jr t) to the common ret; two returns gave two rets (run 75) */
int HDAE5000_HD_WriteOpen(long *slot)
{
    int ret;

    if (HDAE5000_RAM_HdStreamState != 0) {
        HDAE5000_RAM_HdStreamState = 0;
        ret = -1;
    } else {
        HDAE5000_RAM_HdStreamFill = HDAE5000_RAM_HdStreamBuffer;
        HDAE5000_RAM_HdStreamSlot = slot;
        HDAE5000_RAM_HdStreamState = 1;
        ret = 0;
    }
    return ret;
}
