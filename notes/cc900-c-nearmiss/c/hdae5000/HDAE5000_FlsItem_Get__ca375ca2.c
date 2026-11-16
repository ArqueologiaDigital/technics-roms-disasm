/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hd_r4_g1b.c (2026-11-16-57-hd-r7)
   sha256 ca375ca21919a3dac9fa68a8a1d79b8d1237e3e284dab12f57c161be5350de0d (tar-sha256); compiled at -Xr */
/* lane_hd round 4, helper h_small, group 1, form b: hd_r4_g1.c's functions (same names) with these changes:
   - Get / SetAutoLoad / SetAutoStart test the call inside an assignment expression, `if ((r = IsSet()) == -1)`;
   - IsSet returns 0xffff as unsigned int;
   - SongRecord keeps song * 76 in an int local (the ROM's stack slot at (xsp+2)) and builds the result in a
     pointer local; the 1-based song / directory bytes are cast to unsigned char before the arithmetic. */

extern unsigned char HDAE5000_RAM_FlsRecords[];
extern unsigned char HDAE5000_FlsItem_SongRecord_Str_Blank26[];

struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };

#define HD_TABLES ((unsigned char *)0x201632L)
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))

unsigned int HDAE5000_FlsItem_IsSet(unsigned int fls, unsigned int item)
{
    unsigned int r = 0;
    if (FLSB(16, fls, item) == 0 || FLSB(48, fls, item) == 0)
        r = 0xffff;
    return r;
}

void HDAE5000_FlsItem_Get(unsigned int fls, unsigned int item, struct FlsItem *out)
{
    unsigned int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) != 0xffff) {
        out->dir = (unsigned char)(FLSB(16, fls, item) - 1);
        out->song = (unsigned char)(FLSB(48, fls, item) - 1);
        out->as = FLSB(80, fls, item);
        out->al = FLSB(112, fls, item);
    }
}

void HDAE5000_FlsItem_SetAutoLoad(unsigned int fls, unsigned int item, unsigned char on)
{
    unsigned int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) != 0xffff)
        FLSB(112, fls, item) = on;
}

void HDAE5000_FlsItem_SetAutoStart(unsigned int fls, unsigned int item, unsigned char on)
{
    unsigned int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) != 0xffff)
        FLSB(80, fls, item) = on;
}

unsigned char *HDAE5000_FlsItem_SongRecord(unsigned int fls, unsigned int item)
{
    int sofs;
    unsigned char *p;
    if (HDAE5000_FlsItem_IsSet(fls, item) != 0xffff) {
        sofs = (unsigned char)(FLSB(48, fls, item) - 1) * 76;
        p = HD_TABLES + (sofs + ((unsigned long)(unsigned char)(FLSB(16, fls, item) - 1) * 0x4c0 + 0x780));
    } else
        p = HDAE5000_FlsItem_SongRecord_Str_Blank26;
    return p;
}
