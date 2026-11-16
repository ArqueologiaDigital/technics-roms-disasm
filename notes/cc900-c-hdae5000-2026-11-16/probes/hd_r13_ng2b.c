/* lane_hd round 13, helper h_near2, form b: hd_r13_ng2.c's module (same names), FlsItem_Set as a prototype
   definition with `register` on fls instead: in run 66 the `register` item went to HL, the register the ROM gives
   fls, so a register fls may be the one V4.23 moves there, leaving item in BC.  Options: -Xr.
   cc900-module: HDAE5000_HD_StoreTables
*/
#include "hdae_ws.h"

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_FlsRecords[];
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern int HDAE5000_ATA_SoftReset_Status(void);
extern int HDAE5000_HD_WriteTables_Status(void);
extern int HDAE5000_ATA_Standby_Status(void);

struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };

#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))

int HDAE5000_HD_StoreTables(int keep);

int HDAE5000_DirName_SetAndStore(unsigned int dir, char *name, int keep)
{
    HDAE5000_StrNCpy(&HDAE5000_RAM_DirNames[(unsigned long)dir * 16], name, 16);
    return HDAE5000_HD_StoreTables(keep);
}

int HDAE5000_SongName_SetAndStore(unsigned int dir, unsigned int song, char *name, int keep)
{
    HDAE5000_StrNCpy(&HDAE5000_RAM_DirNames[(unsigned long)dir * 0x4c0 + 0x780 + (unsigned long)song * 76], name, 26);
    return HDAE5000_HD_StoreTables(keep);
}

int HDAE5000_FlsName_SetAndStore(unsigned int fls, char *name, int keep)
{
    HDAE5000_StrNCpy(&HDAE5000_RAM_DirNames[(unsigned long)fls * 144 + 0x24180L], name, 16);
    return HDAE5000_HD_StoreTables(keep);
}

int HDAE5000_FlsItem_Set(register unsigned int fls, unsigned int item, struct FlsItem *src, int keep)
{
    FLSB(16, fls, item) = src->dir + 1;
    FLSB(48, fls, item) = src->song + 1;
    FLSB(80, fls, item) = src->as;
    FLSB(112, fls, item) = src->al;
    return HDAE5000_HD_StoreTables(keep);
}

int HDAE5000_HD_StoreTables(int keep)
{
    int st;
    CALLV(HAMA->PlayHalt)(1);
    st = HDAE5000_ATA_SoftReset_Status();
    st |= HDAE5000_HD_WriteTables_Status();
    if (keep != 1)
        st |= HDAE5000_ATA_Standby_Status();
    CALLV(HAMA->PlayStandBy)();
    CALLV(HAMA->EditSwRefresh)();
    return st;
}
