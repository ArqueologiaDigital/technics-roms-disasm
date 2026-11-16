/* The HD song module of hdae5000_ui_display.s: the functions of helper h_calr's C that match; module-local calls are named in cc900-module.
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r13b_song.c.
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

/* stacked words (retd 6): keep, sleep, mask */

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
int HDAE5000_TlxPart_Describe(int part, struct ResInfo *info)
{
    info->addr = (unsigned long)HDAE5000_RAM_LyricBuffer;
    HDAE5000_RAM_LyricFileLength = info->size = HDAE5000_SwapBytes32(TLX_TRLEN) + 0x16;
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

/* PMT: the first write's result is kept (ret); the 0x8000-byte reads that follow are appended */

/* SQT, CMP, RCM: as PMT, but the first write's result is only tested */

/* TLX: the 22-byte TLhd header first (after clearing the buffer), then the TLtr chunk behind it */

/* WA = directory, BC = sleep, DE = keep */

/* stacked words (retd 4): keep, sleep */

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
