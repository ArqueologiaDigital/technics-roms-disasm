/* Functions of hdae5000_ui_display.s.  (hdae5000_song_module2.c, v1.10i port of HDAE5000_SaveSong_Rcm)
   v1.10i: the result is the RCM saver's own (rcm_sv_XAPR_j); HD_WriteClose's result is dropped (v1.15i / v2.x return
   it).  The ROM keeps ret in IZ across the WriteClose call (ld iz,hl after the saver, ld hl,iz at the end).
   cc900-options: -Xr
   cc900-name: SaveRcm_a=HDAE5000_SaveSong_Rcm
   cc900-name: SaveRcm_b=HDAE5000_SaveSong_Rcm
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

struct RcmCtx { unsigned int state; unsigned int dir; unsigned int song; unsigned int result; };

extern int HDAE5000_RcmStream_Write();
extern unsigned int HDAE5000_RcmStream_LastResult(void);
extern long HDAE5000_RcmStream_FreeSpace();
extern int HDAE5000_HD_WriteClose(void);
int HDAE5000_HD_WriteOpen(long *slot);

extern unsigned char HDAE5000_RAM_DirNames[];
extern struct RcmCtx HDAE5000_RAM_RcmStreamState;
extern unsigned int HDAE5000_RAM_RcmStreamDir;
extern unsigned int HDAE5000_RAM_RcmStreamSong;
extern struct RcmCtx HDAE5000_RcmStream_InitialState;

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))

int SaveRcm_a(unsigned int dir, unsigned int song)
{
    int ret = 0;

    HDAE5000_RAM_RcmStreamState = HDAE5000_RcmStream_InitialState;
    HDAE5000_RAM_RcmStreamDir = dir;
    HDAE5000_RAM_RcmStreamSong = song;
    if ((ret = HDAE5000_HD_WriteOpen(&SLOT(6, HDAE5000_RAM_RcmStreamDir, HDAE5000_RAM_RcmStreamSong))) != -1) {
        ret = CALLR(int, HAMA->rcm_sv_XAPR_j)((long)HDAE5000_RcmStream_FreeSpace, (long)HDAE5000_RcmStream_Write,
                                              (long)HDAE5000_RcmStream_LastResult);
        HDAE5000_HD_WriteClose();
    }
    return ret;
}

/* the same with ret declared `register` (in case V4.23 -Xr keeps it in memory otherwise) */
int SaveRcm_b(unsigned int dir, unsigned int song)
{
    register int ret = 0;

    HDAE5000_RAM_RcmStreamState = HDAE5000_RcmStream_InitialState;
    HDAE5000_RAM_RcmStreamDir = dir;
    HDAE5000_RAM_RcmStreamSong = song;
    if ((ret = HDAE5000_HD_WriteOpen(&SLOT(6, HDAE5000_RAM_RcmStreamDir, HDAE5000_RAM_RcmStreamSong))) != -1) {
        ret = CALLR(int, HAMA->rcm_sv_XAPR_j)((long)HDAE5000_RcmStream_FreeSpace, (long)HDAE5000_RcmStream_Write,
                                              (long)HDAE5000_RcmStream_LastResult);
        HDAE5000_HD_WriteClose();
    }
    return ret;
}
