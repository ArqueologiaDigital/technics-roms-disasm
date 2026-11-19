/* Functions of hdae5000_ui_display.s.  (hdae5000_song_io_ui_display__loadpmt_v110_r82.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_song_io_ui_display__loadpmt_v110_r82.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned long addr; unsigned long size; };

extern unsigned char HDAE5000_RAM_DirNames[];

extern int HDAE5000_HD_ReadFile();

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))

int HDAE5000_LoadSong_Pmt(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;

    if (SLOT(1, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(2, (char *)&info);
        CALLV(HAMA->PrePmLoad)();
        ret = HDAE5000_HD_ReadFile(info.addr, info.size, &SLOT(1, dir, song));
        CALLV(HAMA->PostPmLoad)(ret);
    }
    return ret;
}
