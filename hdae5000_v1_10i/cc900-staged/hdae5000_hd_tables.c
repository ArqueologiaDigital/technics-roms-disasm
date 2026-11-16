/* hdae5000_v1_10i: the functions of hdae5000/cc900-staged/hdae5000_hd_tables.c that V4.23 reproduces unchanged in HD-AE5000 v1.10i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_hd_tables.c.
   cc900-options: -Xr
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
