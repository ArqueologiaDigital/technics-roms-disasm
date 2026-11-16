/* lane_hd round 4, helper h_small, group 2 (one calr group = one module), in ROM address order:
   HDAE5000_DirName_SetAndStore, _SongName_SetAndStore, _FlsName_SetAndStore, _FlsItem_Set, _HD_StoreTables.
   Options: -Xr.
   - The table block at HDAE5000_RAM_DirNames (0x201632): directory names [120][16], song records at +0x780
     (dir * 0x4c0 + song * 76), FLS records at +0x24180 (fls * 144).  The ROM loads the base with `ld xR, sym`
     (immediate) after the index.  V4.23 micro tests (runs 2026-11-10-5 r2_08_04, 2026-11-16-49 FlsList_BuildPage)
     give exactly that for `&arr[unsigned index]` passed as a call ARGUMENT, and `lda` for the same address returned
     or assigned (r3_00_02, r2_08_16, DirName_Address): every table address here is a StrNCpy argument, written
     `&HDAE5000_RAM_DirNames[index]`.
   - FlsItem_Set's fields use run 52's integer-address idiom (`lda xR,(FlsRecords+N)` after the index); its
     `+ 1` is done in byte width by V4.23 (`inc 1,a`).
   - The 4th argument (store flag) of SongName_SetAndStore and FlsItem_Set is on the stack; `retd 2` pops it.
   - HD_StoreTables: the HamaFn calls through CALLV; the status OR in IZ. */
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

int HDAE5000_FlsItem_Set(unsigned int fls, unsigned int item, struct FlsItem *src, int keep)
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
