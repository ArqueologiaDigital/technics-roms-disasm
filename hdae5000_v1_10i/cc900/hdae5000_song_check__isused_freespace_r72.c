/* Functions of hdae5000_ui_display.s.  (hdae5000_song_check__isused_freespace_r72.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_song_check__isused_freespace_r72.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned long addr; unsigned long size; };

extern unsigned long HDAE5000_HD_ClusterCount(unsigned long bytes);
extern unsigned long HDAE5000_HD_CountFreeClusters_Status(void);

extern unsigned char HDAE5000_RAM_DirNames[];

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(unsigned long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))

/* v1.15i: eight song parts (no TLX slot 8) */
int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song)
{
    if (SLOT(0, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(1, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(2, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(3, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(4, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(5, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(6, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(7, dir, song) != 0xffffffffUL) return 0;
    return -1;
}

/* v1.15i: no TLX part, so no "mask & 0x100: += 0x5000" */
int HDAE5000_Song_CheckFreeSpace(unsigned int mask)
{
    int ret;
    struct ResInfo info;
    unsigned long total;

    ret = 0;
    total = 0;
    if (mask & 0x001) {
        CALLV(HAMA->GetResouceInfo)(0, (char *)&info);
        total += info.size;
        CALLV(HAMA->GetResouceInfo)(1, (char *)&info);
        total += info.size;
    }
    if (mask & 0x002) {
        CALLV(HAMA->GetResouceInfo)(2, (char *)&info);
        total += info.size;
    }
    if (mask & 0x004) {
        CALLV(HAMA->GetResouceInfo)(3, (char *)&info);
        total += info.size;
        total += CALLR(unsigned long, HAMA->SeqSavePre)();
    }
    if (mask & 0x008)
        total += CALLR(unsigned long, HAMA->cmp_sv_mae)();
    if (mask & 0x010) {
        info.size = 0x72aaL;
        total += info.size;
    }
    if (mask & 0x020)
        total += CALLR(unsigned long, HAMA->msp_sv_mae)();
    if (mask & 0x040) {
        CALLV(HAMA->GetResouceInfo)(8, (char *)&info);
        total += info.size;
    }
    if (mask & 0x080) {
        CALLV(HAMA->GetResouceInfo)(9, (char *)&info);
        total += info.size;
    }
    total = HDAE5000_HD_ClusterCount(total);
    if (HDAE5000_HD_CountFreeClusters_Status() <= total)
        ret = -1;
    return ret;
}
