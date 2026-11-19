/* hdae5000_v2_01i: per-tree C written from the tree's hand source, MATCH in run 2026-11-19-62-hd-r74-v201 (hd_r74v_song_module__tlx.c).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r74v_song_module__tlx.c.
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
struct TlxHdr { unsigned char pad[18]; unsigned long trlen; };

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);

extern int HDAE5000_HD_WriteFile();
unsigned long HDAE5000_RoundUpToSector(unsigned long n);

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];

/* HDAE5000_CopyFdSongToHd_Tlx_Str_rb / _Str_TLX, under ram_<hex> names (they share their first 31 characters) */
extern char ram_2f8446[];
extern char ram_2f8440[];
#define STR_TLX ram_2f8440

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define HAS(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))

/* TLX: the 22-byte TLhd header, then the whole file again from the buffer's start, its length the TLtr length
   word as read (not byte-swapped) + 22, rounded up to a sector */
int HDAE5000_CopyFdSongToHd_Tlx(unsigned int dir, unsigned int song, char *fdname)
{
    int ret = 0;
    struct ResInfo info;
    char fname[14];

    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_TLX);
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2f8446) >= 0) {
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x16L);
        info.size = HDAE5000_RoundUpToSector(((struct TlxHdr *)HDAE5000_RAM_HdStreamBuffer)->trlen + 0x16);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, info.size);
        ret = HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, info.size, &SLOT(8, dir, song));
        HAS(8, dir, song) = 1;
        CALLV(HAMA->fclose_ext)();
    } else
        ret = -1;
    return ret;
}
