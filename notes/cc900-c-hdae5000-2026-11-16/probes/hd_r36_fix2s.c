/* hd_r36_fix2s.c (helper h_fix2, lane_hd round 36): HDAE5000_LoadSong_Tlx alone, from hd_r27_b_songb.c, with
   variants.  Options: -Xr.
   What run 2026-11-16-119-hd-r30 showed (hd_r27_b_song.c and hd_r27_b_songb.c gave the same code, so `register` on
   the local changes nothing):
   - the ROM keeps ret in IZ, saves only IZ (16-bit push, frame 24) and holds the song * 76 product of ALL THREE
     slot-address computations in a stack temporary (three 4-byte temporaries below `info`);
   - V4.23 also keeps ret in IZ, but only the product of the `if` condition goes to the stack: in the two
     HD_ReadFile statements, where ret's old value is dead, it takes the whole XIZ for the product, so it saves XIZ
     (32-bit push) and needs one temporary less (frame 20).  Every other instruction is the same.
   So the C must make V4.23 treat IZ as occupied while the arguments of the two reads are evaluated.  No rule for
   that is known; the forms below are guesses at what could change the live range V4.23 computes:
     HDAE5000_LoadSong_Tlx  ret declared without initialiser and set by a statement, `ret = 0;`
     LdTlx_g                one exit label: the three tests jump to `done` with goto (no nested blocks)
     LdTlx_u                ret unsigned (the tests compare with 0xffff), declared after `info`
   cc900-name: LdTlx_g=HDAE5000_LoadSong_Tlx
   cc900-name: LdTlx_u=HDAE5000_LoadSong_Tlx
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

extern int HDAE5000_HD_ReadFile();
extern void HDAE5000_Lyrics_ClearBuffer(void);
/* this module (calr): no prototype, the address of `info` is evaluated early through the (char *) cast */
extern int HDAE5000_TlxPart_Describe();

extern unsigned char HDAE5000_RAM_DirNames[];

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))

int HDAE5000_LoadSong_Tlx(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info;

    ret = 0;
    if (SLOT(8, dir, song) != -1L) {
        HDAE5000_Lyrics_ClearBuffer();
        HDAE5000_TlxPart_Describe(10, (char *)&info);
        ret = HDAE5000_HD_ReadFile(info.addr, 0x16L, &SLOT(8, dir, song));
        if (ret != -1) {
            HDAE5000_TlxPart_Describe(10, (char *)&info);
            ret = HDAE5000_HD_ReadFile(info.addr, info.size, &SLOT(8, dir, song));
        }
    }
    return ret;
}

int LdTlx_g(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;

    if (SLOT(8, dir, song) == -1L)
        goto done;
    HDAE5000_Lyrics_ClearBuffer();
    HDAE5000_TlxPart_Describe(10, (char *)&info);
    ret = HDAE5000_HD_ReadFile(info.addr, 0x16L, &SLOT(8, dir, song));
    if (ret == -1)
        goto done;
    HDAE5000_TlxPart_Describe(10, (char *)&info);
    ret = HDAE5000_HD_ReadFile(info.addr, info.size, &SLOT(8, dir, song));
done:
    return ret;
}

unsigned int LdTlx_u(unsigned int dir, unsigned int song)
{
    struct ResInfo info;
    unsigned int ret = 0;

    if (SLOT(8, dir, song) != -1L) {
        HDAE5000_Lyrics_ClearBuffer();
        HDAE5000_TlxPart_Describe(10, (char *)&info);
        ret = HDAE5000_HD_ReadFile(info.addr, 0x16L, &SLOT(8, dir, song));
        if (ret != 0xffff) {
            HDAE5000_TlxPart_Describe(10, (char *)&info);
            ret = HDAE5000_HD_ReadFile(info.addr, info.size, &SLOT(8, dir, song));
        }
    }
    return ret;
}
