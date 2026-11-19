/* Functions of hdae5000_ui_display.s.  (hdae5000_song_module2.c, v1.10i port of HDAE5000_LoadSong, HDAE5000_SaveSong,
   HDAE5000_CopyFdSongToHd, HDAE5000_DeleteDirectory, HDAE5000_DeleteSongParts)
   v1.x has eight song parts (no TLX): the v2.06i C's TLX steps are dropped, the "all parts" mask is 0xff
   (ld de,0x00ff where v2.06i has 0x01ff), and CopyFdSongToHd names the song from the floppy name alone (no .TTX
   title file: no fname buffer, no fopen / fread / fclose; the ROM's frame is 14 bytes smaller).
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

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);

extern int HDAE5000_ATA_SoftReset_Status(void);
extern int HDAE5000_ATA_Standby_Status(void);
extern int HDAE5000_HD_WriteTables_Status(void);

/* the module's other functions (cc900-module), defined elsewhere */
extern int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song);
extern int HDAE5000_Song_CheckFreeSpace(unsigned int mask);
extern int HDAE5000_LoadSong_Lsw(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Pmt(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Sqt(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Cmp(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Tm(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Msp(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Rcm(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Md(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Lsw(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Pmt(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Sqt(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Cmp(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Tm(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Msp(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Rcm(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Md(unsigned int dir, unsigned int song);
extern int HDAE5000_CopyFdSongToHd_Lsw(unsigned int dir, unsigned int song, char *fdname);
extern int HDAE5000_CopyFdSongToHd_Pmt(unsigned int dir, unsigned int song, char *fdname);
extern int HDAE5000_CopyFdSongToHd_Sqt(unsigned int dir, unsigned int song, char *fdname);
extern int HDAE5000_CopyFdSongToHd_Cmp(unsigned int dir, unsigned int song, char *fdname);
extern int HDAE5000_CopyFdSongToHd_Tm(unsigned int dir, unsigned int song, char *fdname);
extern int HDAE5000_CopyFdSongToHd_Msp(unsigned int dir, unsigned int song, char *fdname);
extern int HDAE5000_CopyFdSongToHd_Rcm(unsigned int dir, unsigned int song, char *fdname);
extern int HDAE5000_CopyFdSongToHd_Md(unsigned int dir, unsigned int song, char *fdname);
extern void HDAE5000_DeleteSongPart_Lsw(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Pmt(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Sqt(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Cmp(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Tm(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Msp(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Rcm(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Md(unsigned int dir, unsigned int song);
extern void HDAE5000_Fls_ForgetSong(unsigned int dir, unsigned int song);
void HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int sleep, int keep);

extern unsigned char HDAE5000_RAM_DirNames[];

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)

/* the stacked words (retd 4; V4.23 puts the last parameter lowest): keep = 1 leaves the drive spinning (xsp+12),
   sleep = 1 puts the main task to sleep (xsp+14) */
int HDAE5000_LoadSong(unsigned int dir, unsigned int song, unsigned int mask, int sleep, int keep)
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
    if (keep != 1)
        HDAE5000_ATA_Standby_Status();
    if (sleep == 1)
        CALLV(ROOT->WakeUpMainTask)();
    CALLV(HAMA->PlayStandBy)();
    CALLV(HAMA->EditSwRefresh)();
    return ret;
}

/* stacked words (retd 6), lowest first: keep (xsp+18), sleep, mask (xsp+22) */
int HDAE5000_SaveSong(unsigned int dir, unsigned int song, char *name, unsigned int mask, int sleep, int keep)
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
        if (ret != -1) {
            HDAE5000_StrNCpy(&HDAE5000_RAM_DirNames[SONG_OFS(dir, song)], name, 26);
            HDAE5000_HD_WriteTables_Status();
        } else
            HDAE5000_DeleteSongParts(dir, song, 0xff, 0, keep);
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

/* XDE = the floppy song's 8-character file name; stacked words (retd 6), lowest first: keep, sleep, mask.
   v1.x: the song is named from the file name's last six characters, padded with blanks (no .TTX file) */
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
        if (ret != -1) {
            HDAE5000_MemFill(name, ' ', 26);
            name[26] = 0;
            HDAE5000_MemCopy(name, fdname + 2, 6);
            HDAE5000_StrNCpy(&HDAE5000_RAM_DirNames[SONG_OFS(dir, song)], name, 26);
            HDAE5000_HD_WriteTables_Status();
        } else
            HDAE5000_DeleteSongParts(dir, song, 0xff, 0, keep);
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

/* stacked words (retd 4), lowest first: keep (xsp+12), sleep (xsp+14) */
void HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int sleep, int keep)
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
