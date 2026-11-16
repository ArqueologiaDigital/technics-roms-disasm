/* lane_hd round 4, helper h_small, group 2, form b: hd_r4_g2.c's functions (same names) with the table block as
   typed arrays instead of byte offsets, in case V4.23 picks `ld xR, sym` for a row of a 2-D array argument
   (FlsList_BuildPage's `FlsListText[i]` did, run 49):
   - DirName_SetAndStore: `HDAE5000_RAM_DirNames[dir]` of a [][16] array;
   - SongName / FlsName: the byte table addressed as `HDAE5000_RAM_DirNames + offset` (pointer plus integer);
   - the *_SetAndStore functions void (the ROM leaves StoreTables' HL in place either way);
   - HD_StoreTables with an unsigned status. */
#include "hdae_ws.h"

extern unsigned char HDAE5000_RAM_DirNames[][16];
extern unsigned char HDAE5000_RAM_FlsRecords[];
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern unsigned int HDAE5000_ATA_SoftReset_Status(void);
extern unsigned int HDAE5000_HD_WriteTables_Status(void);
extern unsigned int HDAE5000_ATA_Standby_Status(void);

struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };

#define TBL ((unsigned char *)HDAE5000_RAM_DirNames)
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))

unsigned int HDAE5000_HD_StoreTables(int keep);

void HDAE5000_DirName_SetAndStore(unsigned int dir, char *name, int keep)
{
    HDAE5000_StrNCpy(HDAE5000_RAM_DirNames[dir], name, 16);
    HDAE5000_HD_StoreTables(keep);
}

void HDAE5000_SongName_SetAndStore(unsigned int dir, unsigned int song, char *name, int keep)
{
    HDAE5000_StrNCpy(TBL + ((unsigned long)dir * 0x4c0 + 0x780 + (unsigned long)song * 76), name, 26);
    HDAE5000_HD_StoreTables(keep);
}

void HDAE5000_FlsName_SetAndStore(unsigned int fls, char *name, int keep)
{
    HDAE5000_StrNCpy(TBL + ((unsigned long)fls * 144 + 0x24180L), name, 16);
    HDAE5000_HD_StoreTables(keep);
}

void HDAE5000_FlsItem_Set(unsigned int fls, unsigned int item, struct FlsItem *src, int keep)
{
    FLSB(16, fls, item) = src->dir + 1;
    FLSB(48, fls, item) = src->song + 1;
    FLSB(80, fls, item) = src->as;
    FLSB(112, fls, item) = src->al;
    HDAE5000_HD_StoreTables(keep);
}

unsigned int HDAE5000_HD_StoreTables(int keep)
{
    unsigned int st;
    CALLV(HAMA->PlayHalt)(1);
    st = HDAE5000_ATA_SoftReset_Status();
    st |= HDAE5000_HD_WriteTables_Status();
    if (keep != 1)
        st |= HDAE5000_ATA_Standby_Status();
    CALLV(HAMA->PlayStandBy)();
    CALLV(HAMA->EditSwRefresh)();
    return st;
}
