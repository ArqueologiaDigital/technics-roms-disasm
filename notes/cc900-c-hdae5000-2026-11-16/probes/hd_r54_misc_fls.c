/* hd_r54_misc_fls.c (helper h_misc, lane_hd round 54): five small functions of hdae5000_ui_display.s that call
   nothing of their module (each its own calr group; none calls another): HDAE5000_NameHistory_Recall (0x28b37b,
   56 B), HDAE5000_Count_Active_Files (0x28b3bf, 43 B), HDAE5000_FlsItem_SetDir (0x2900c2, 34 B),
   HDAE5000_FlsItem_SetSong (0x2900e4, 34 B), HDAE5000_RcmStream_FreeSpace (0x294152, 19 B).  No earlier probe
   defined any of them (the probes only called them).
   cc900-options: -Xr
   cc900-name: FlsItemSetDir_b=HDAE5000_FlsItem_SetDir
   cc900-name: FlsItemSetSong_b=HDAE5000_FlsItem_SetSong
   cc900-name: CountActive_b=HDAE5000_Count_Active_Files
   cc900-name: NameHistRecall_b=HDAE5000_NameHistory_Recall
   cc900-name: NameHistRecall_c=HDAE5000_NameHistory_Recall
   cc900-name: NameHistRecall_d=HDAE5000_NameHistory_Recall
   cc900-name: RcmFreeSpace_b=HDAE5000_RcmStream_FreeSpace

   NameHistory_Recall (ROM): p in XHL = &name[idx] (`ld c,(xwa+1); extz bc; muls bc,27; inc 4,bc; lda xhl,(xwa+bc)`)
   when count (+0) is not 0, else 0 (the else body last); then idx (+1) == 0 ? (count == 5 ? idx = 4 : idx =
   count - 1) : idx--.  The zero tests are `cp (mem),0` but count == 5 loads count first (`ld c,(xwa); cp c,5`):
     HDAE5000_NameHistory_Recall  a struct, plain ifs
     NameHistRecall_b             count == 5 as a switch on count (a switch loads its value into a register)
     NameHistRecall_c             a flat `unsigned char *` with the offset 4 + idx * 27
     NameHistRecall_d             signed `char` count / idx
   Count_Active_Files (ROM): n in HL, i in DE, `ret nc` entry test, the byte at FdList + 0x114 + i through the
   flat-array idiom (`ld wa,de; extz xwa; add xwa,0x114; ld xbc,imm; add xbc,xwa; cp (xbc),1`).
     HDAE5000_Count_Active_Files  locals n, i;   CountActive_b  locals i, n
   FlsItem_SetDir / _SetSong (ROM): byte +16 / +48 of FLS item = E + 1, return HL = 0, the FLSB idiom of the matched
   FlsItem_SetAutoStart (cc900/hdae5000_flsitem_set.c: extz item first, then fls, *144 by shifts).
     HDAE5000_FlsItem_Set*  `unsigned int dir` (the callers load DE);  *_b  an `unsigned char` parameter (in E)
   RcmStream_FreeSpace (ROM): 16-byte struct on the stack, `lda xwa,(xsp)` straight into the argument,
   free (+12) << 10 in XHL.   HDAE5000_RcmStream_FreeSpace  `<< 10`;  RcmFreeSpace_b  `* 1024`
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

char *HDAE5000_NameHistory_Recall(struct NameHist *h)
{
    char *p;

    if (h->count != 0) {
        p = h->name[h->idx];
        if (h->idx == 0) {
            if (h->count == 5)
                h->idx = 4;
            else
                h->idx = h->count - 1;
        } else
            h->idx--;
    } else
        p = 0;
    return p;
}

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

char *NameHistRecall_c(unsigned char *h)
{
    char *p;

    if (h[0] != 0) {
        p = (char *)&h[h[1] * 27 + 4];
        if (h[1] == 0) {
            if (h[0] == 5)
                h[1] = 4;
            else
                h[1] = h[0] - 1;
        } else
            h[1]--;
    } else
        p = 0;
    return p;
}

char *NameHistRecall_d(struct NameHistS *h)
{
    char *p;

    if (h->count != 0) {
        p = h->name[h->idx];
        if (h->idx == 0) {
            if (h->count == 5)
                h->idx = 4;
            else
                h->idx = h->count - 1;
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

unsigned int CountActive_b(void)
{
    unsigned int i;
    unsigned int n;

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

int FlsItemSetDir_b(unsigned int fls, unsigned int item, unsigned char dir)
{
    FLSB(16, fls, item) = dir + 1;
    return 0;
}

int HDAE5000_FlsItem_SetSong(unsigned int fls, unsigned int item, unsigned int song)
{
    FLSB(48, fls, item) = song + 1;
    return 0;
}

int FlsItemSetSong_b(unsigned int fls, unsigned int item, unsigned char song)
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

long RcmFreeSpace_b(void)
{
    struct DiskUsage u;

    HDAE5000_HD_GetDiskUsage(&u);
    return u.free * 1024;
}
