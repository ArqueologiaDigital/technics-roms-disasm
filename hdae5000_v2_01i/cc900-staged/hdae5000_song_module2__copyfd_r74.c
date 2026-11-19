/* hdae5000_v2_01i: per-tree C written from the tree's hand source, MATCH in run 2026-11-19-62-hd-r74-v201 (hd_r74v_song_module2__copyfd.c).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r74v_song_module2__copyfd.c.
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

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);

extern int HDAE5000_ATA_SoftReset_Status(void);
extern int HDAE5000_ATA_Standby_Status(void);
extern int HDAE5000_HD_WriteTables_Status(void);

/* the module's other functions (cc900-module), defined elsewhere */
extern int HDAE5000_Song_CheckFreeSpace(unsigned int mask);
extern void HDAE5000_DeleteSongPart_Lsw(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Pmt(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Sqt(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Cmp(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Tm(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Msp(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Rcm(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Md(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Tlx(unsigned int dir, unsigned int song);
void HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int sleep, int keep);

extern unsigned char HDAE5000_RAM_DirNames[];

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)

int HDAE5000_CopyFdSongToHd_Lsw(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Pmt(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Sqt(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Cmp(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Tm(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Msp(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Rcm(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Md(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Tlx(unsigned int dir, unsigned int song, char *fdname);

/* XDE = the floppy song's 8-character file name; stacked words (retd 6), lowest first: keep, sleep, mask (xsp+50) */
int HDAE5000_CopyFdSongToHd(unsigned int dir, unsigned int song, char *fdname, unsigned int mask, int sleep,
                            int keep)
{
    int ret = 0;
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
            HDAE5000_MemCopy(name, fdname + 2, 6);
            HDAE5000_StrNCpy(&HDAE5000_RAM_DirNames[SONG_OFS(dir, song)], name, 26);
            HDAE5000_HD_WriteTables_Status();
        } else
            HDAE5000_DeleteSongParts(dir, song, 0x1ff, 0, keep);
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
