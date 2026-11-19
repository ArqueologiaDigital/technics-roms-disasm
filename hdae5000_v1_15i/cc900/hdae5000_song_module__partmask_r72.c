/* Functions of hdae5000_ui_display.s.  (hdae5000_song_module__partmask_r72.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_song_module__partmask_r72.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
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
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song);

extern unsigned char HDAE5000_RAM_DirNames[];

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))

/* v1.15i: eight song parts (no TLX), so no slot 8 / bit 0x100 */
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
    } else
        mask = 0xffff;
    return mask;
}
