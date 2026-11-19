/* Functions of hdae5000_ui_display.s.  (hdae5000_song_module.c, v1.15i port of HDAE5000_CopyFdSongToHd_Sqt / _Cmp / _Rcm)
   cc900-options: -Xr
   cc900-module: HDAE5000_Song_IsUsed HDAE5000_Song_CheckFreeSpace HDAE5000_Song_PartMask
   cc900-module: HDAE5000_LoadSong_Lsw HDAE5000_LoadSong_Pmt HDAE5000_LoadSong_Sqt HDAE5000_LoadSong_Cmp HDAE5000_LoadSong_Tm
   cc900-module: HDAE5000_LoadSong_Msp HDAE5000_LoadSong_Rcm HDAE5000_LoadSong_Md
   cc900-module: HDAE5000_SaveSong_Lsw HDAE5000_SaveSong_Pmt HDAE5000_SaveSong_Sqt HDAE5000_SaveSong_Cmp HDAE5000_SaveSong_Tm
   cc900-module: HDAE5000_SaveSong_Msp HDAE5000_SaveSong_Rcm HDAE5000_SaveSong_Md
   cc900-module: HDAE5000_CopyFdSongToHd_Lsw HDAE5000_CopyFdSongToHd_Pmt HDAE5000_CopyFdSongToHd_Sqt HDAE5000_CopyFdSongToHd_Cmp
   cc900-module: HDAE5000_CopyFdSongToHd_Tm HDAE5000_CopyFdSongToHd_Msp HDAE5000_CopyFdSongToHd_Rcm HDAE5000_CopyFdSongToHd_Md
   cc900-module: HDAE5000_DeleteSongPart_Lsw HDAE5000_DeleteSongPart_Pmt HDAE5000_DeleteSongPart_Sqt HDAE5000_DeleteSongPart_Cmp
   cc900-module: HDAE5000_DeleteSongPart_Tm HDAE5000_DeleteSongPart_Msp HDAE5000_DeleteSongPart_Rcm HDAE5000_DeleteSongPart_Md
   cc900-module: HDAE5000_DeleteSongParts HDAE5000_Fls_ForgetSong
   cc900-module: HDAE5000_RoundUpToSector HDAE5000_HD_WriteOpen HDAE5000_HD_WriteClose
   cc900-name: CopyFdSqt_c=HDAE5000_CopyFdSongToHd_Sqt
   cc900-name: CopyFdCmp_c=HDAE5000_CopyFdSongToHd_Cmp
   cc900-name: CopyFdRcm_c=HDAE5000_CopyFdSongToHd_Rcm
   cc900-name: CopyFdSqt_d=HDAE5000_CopyFdSongToHd_Sqt
   r2 (round 72: forms a/b gave a 30-byte frame, the ROM's is 32): the ROM copies n into an argument temporary
   before computing the slot address, as for an expression, where V4.23 passed the plain variable n straight from
   its home slot; so the first write's size is written as an expression: (unsigned long)n (forms c), (long)n (form d)
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);

extern int HDAE5000_HD_WriteFile();
extern int HDAE5000_HD_AppendFile();
unsigned long HDAE5000_RoundUpToSector(unsigned long n);

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];

/* the "rb" fopen modes (CopyFdSongToHd_<Part>_Str_rb) and the extensions (_<Part>_Str_<PART>) */
extern char ram_2e0a30[], ram_2e0a3a[], ram_2e0a56[];
extern char ram_2e0a2a[], ram_2e0a34[], ram_2e0a50[];
#define STR_SQT ram_2e0a2a
#define STR_CMP ram_2e0a34
#define STR_RCM ram_2e0a50

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define HAS(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))

/* v1.15i SQT, CMP, RCM: 0x10000-byte reads; the first write takes the count as read (not rounded up to a sector);
   an appended read is skipped when it is 0 bytes (or xwa,xwa / jr z), not when <= 0 */

int CopyFdSqt_c(unsigned int dir, unsigned int song, char *fdname)
{
    int ret = 0;
    long n;
    char fname[14];
    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_SQT);
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2e0a30) < 0)
        return -1;
    n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x10000L);
    if (HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, (unsigned long)n,
                              &SLOT(2, dir, song)) == -1)
        return -1;
    while (n == 0x10000L) {
        n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x10000L);
        if (n != 0) {
            if ((ret = HDAE5000_HD_AppendFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                              HDAE5000_RoundUpToSector(n), &SLOT(2, dir, song))) == -1)
                break;
        }
    }
    HAS(2, dir, song) = 1;
    CALLV(HAMA->fclose_ext)();
    return ret;
}

int CopyFdCmp_c(unsigned int dir, unsigned int song, char *fdname)
{
    int ret = 0;
    long n;
    char fname[14];
    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_CMP);
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2e0a3a) < 0)
        return -1;
    n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x10000L);
    if (HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, (unsigned long)n,
                              &SLOT(3, dir, song)) == -1)
        return -1;
    while (n == 0x10000L) {
        n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x10000L);
        if (n != 0) {
            if ((ret = HDAE5000_HD_AppendFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                              HDAE5000_RoundUpToSector(n), &SLOT(3, dir, song))) == -1)
                break;
        }
    }
    HAS(3, dir, song) = 1;
    CALLV(HAMA->fclose_ext)();
    return ret;
}

int CopyFdRcm_c(unsigned int dir, unsigned int song, char *fdname)
{
    int ret = 0;
    long n;
    char fname[14];
    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_RCM);
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2e0a56) < 0)
        return -1;
    n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x10000L);
    if (HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, (unsigned long)n,
                              &SLOT(6, dir, song)) == -1)
        return -1;
    while (n == 0x10000L) {
        n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x10000L);
        if (n != 0) {
            if ((ret = HDAE5000_HD_AppendFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                              HDAE5000_RoundUpToSector(n), &SLOT(6, dir, song))) == -1)
                break;
        }
    }
    HAS(6, dir, song) = 1;
    CALLV(HAMA->fclose_ext)();
    return ret;
}

/* SQT with (long)n as the first write's size */
int CopyFdSqt_d(unsigned int dir, unsigned int song, char *fdname)
{
    int ret = 0;
    long n;
    char fname[14];
    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_SQT);
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2e0a30) < 0)
        return -1;
    n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x10000L);
    if (HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, (long)n, &SLOT(2, dir, song)) == -1)
        return -1;
    while (n == 0x10000L) {
        n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x10000L);
        if (n != 0) {
            if ((ret = HDAE5000_HD_AppendFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                              HDAE5000_RoundUpToSector(n), &SLOT(2, dir, song))) == -1)
                break;
        }
    }
    HAS(2, dir, song) = 1;
    CALLV(HAMA->fclose_ext)();
    return ret;
}
