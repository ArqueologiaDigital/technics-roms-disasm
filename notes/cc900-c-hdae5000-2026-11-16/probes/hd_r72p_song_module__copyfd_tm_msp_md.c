/* Functions of hdae5000_ui_display.s.  (hdae5000_song_module.c, v1.15i port of HDAE5000_CopyFdSongToHd_Tm / _Msp / _Md)
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
   cc900-name: CopyFdTm_a=HDAE5000_CopyFdSongToHd_Tm
   cc900-name: CopyFdMsp_a=HDAE5000_CopyFdSongToHd_Msp
   cc900-name: CopyFdMd_a=HDAE5000_CopyFdSongToHd_Md
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned long addr; unsigned long size; };

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);

extern int HDAE5000_HD_WriteFile();
unsigned long HDAE5000_RoundUpToSector(unsigned long n);

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];

/* the "rb" fopen modes (CopyFdSongToHd_<Part>_Str_rb) and the extensions (_<Part>_Str_<PART>) */
extern char ram_2e0a42[], ram_2e0a4c[], ram_2e0a5e[];
extern char ram_2e0a3e[], ram_2e0a46[], ram_2e0a5a[];
#define STR_TM  ram_2e0a3e
#define STR_MSP ram_2e0a46
#define STR_MD  ram_2e0a5a

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define HAS(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))

/* v1.15i TM, MSP: the write takes info.size itself, not rounded up to a sector (the ROM keeps the member's address
   in a temporary and loads through it after the slot address is computed) */

int CopyFdTm_a(unsigned int dir, unsigned int song, char *fdname)
{
    int ret = 0;
    struct ResInfo info;
    char fname[14];
    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_TM);
    CALLV(HAMA->GetResouceInfo)(6, (char *)&info);
    info.size = 0x72aaL;
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2e0a42) >= 0) {
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, info.size);
        ret = HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, info.size, &SLOT(4, dir, song));
        HAS(4, dir, song) = 1;
        CALLV(HAMA->fclose_ext)();
    } else
        ret = -1;
    return ret;
}

int CopyFdMsp_a(unsigned int dir, unsigned int song, char *fdname)
{
    int ret = 0;
    struct ResInfo info;
    char fname[14];
    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_MSP);
    CALLV(HAMA->GetResouceInfo)(7, (char *)&info);
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2e0a4c) >= 0) {
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, info.size);
        ret = HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, info.size, &SLOT(5, dir, song));
        HAS(5, dir, song) = 1;
        CALLV(HAMA->fclose_ext)();
    } else
        ret = -1;
    return ret;
}

/* v1.15i MD: the resource size is rounded up to a sector right after GetResouceInfo(9), and the read and the
   write both take the rounded info.size */
int CopyFdMd_a(unsigned int dir, unsigned int song, char *fdname)
{
    int ret = 0;
    struct ResInfo info;
    char fname[14];
    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_MD);
    CALLV(HAMA->GetResouceInfo)(9, (char *)&info);
    info.size = HDAE5000_RoundUpToSector(info.size);
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2e0a5e) >= 0) {
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, info.size);
        ret = HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, info.size, &SLOT(7, dir, song));
        HAS(7, dir, song) = 1;
        CALLV(HAMA->fclose_ext)();
    } else
        ret = -1;
    return ret;
}
