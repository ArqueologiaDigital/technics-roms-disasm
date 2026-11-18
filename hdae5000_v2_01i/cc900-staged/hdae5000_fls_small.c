/* hdae5000_v2_01i: the functions of hdae5000/cc900-staged/hdae5000_fls_small.c that V4.23 reproduces unchanged in HD-AE5000 v2.01i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_fls_small.c.
   cc900-options: -Xr
   cc900-name: NameHistRecall_b=HDAE5000_NameHistory_Recall
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct NameHist { unsigned char count; unsigned char idx; unsigned char pad[2]; char name[5][27]; };
struct NameHistS { char count; char idx; char pad[2]; char name[5][27]; };
struct DiskUsage { unsigned long drive; unsigned long system; unsigned long data; unsigned long free; };

extern void HDAE5000_HD_GetDiskUsage(struct DiskUsage *u);

extern unsigned char HDAE5000_RAM_FlsRecords[];
extern unsigned char ram_22aa9c[];      /* HDAE5000_RAM_FdList as a flat array: sel[20] at 0x114 */

#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))

char *NameHistRecall_b(struct NameHist *h)
{
    char *p;

    if (h->count != 0) {
        p = h->name[h->idx];
        if (h->idx == 0) {
            switch (h->count) {
            case 5:
                h->idx = 4;
                break;
            default:
                h->idx = h->count - 1;
                break;
            }
        } else
            h->idx--;
    } else
        p = 0;
    return p;
}

/* how many of the 20 floppy entries are selected (byte 1) */
unsigned int HDAE5000_Count_Active_Files(void)
{
    unsigned int n;
    unsigned int i;

    n = 0;
    for (i = 0; i < 20; i++)
        if (ram_22aa9c[(unsigned long)i + 0x114] == 1)
            n++;
    return n;
}

int HDAE5000_FlsItem_SetDir(unsigned int fls, unsigned int item, unsigned int dir)
{
    FLSB(16, fls, item) = dir + 1;
    return 0;
}

int HDAE5000_FlsItem_SetSong(unsigned int fls, unsigned int item, unsigned int song)
{
    FLSB(48, fls, item) = song + 1;
    return 0;
}

/* the disk's free space for the RCM save (HDAE5000_HD_GetDiskUsage's free field, units of 10,000 B, << 10) */
long HDAE5000_RcmStream_FreeSpace(void)
{
    struct DiskUsage u;

    HDAE5000_HD_GetDiskUsage(&u);
    return u.free << 10;
}
