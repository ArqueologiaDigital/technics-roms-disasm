/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hd_r4_g1.c (2026-11-16-57-hd-r7)
   sha256 066af0c4dafed1ff25efe3ba5cb8854388f832ba3df44266ec51f9da029f8928 (tar-sha256); compiled at -Xr */
/* lane_hd round 4, helper h_small, group 1 (one calr group = one module): the FLS item accessors
   HDAE5000_FlsItem_IsSet, _Get, _SetAutoLoad, _SetAutoStart, _SongRecord, in ROM address order.  Options: -Xr.
   FLS record (HDAE5000_RAM_FlsRecords, 120 x 144 B): 16-byte name, then four 32-byte item columns at +16 (dir + 1,
   0 = free), +48 (song + 1), +80 (AS), +112 (AL).  Item fields are written with run 2026-11-16-52's integer-address
   idiom, which gives the ROM's `lda xR,(sym+N:24)` after the index.
   - V4.23 computes `unsigned char - 1` in byte width and widens afterwards (`dec 1,a; extz`), as the ROM does;
   - the callers' `ld wa,hl; cp wa,0xffff` is a local holding the call's result (micro assign_expr: ae_i_call);
     SongRecord compares HL directly, so it tests the call itself;
   - SongRecord's table base is `ld xhl, imm` after the index: written as a constant pointer (HD_TABLES).
   Unsure: SongRecord's song * 76 as one expression (form a) or a local (form b, hd_r4_g1b.c). */

extern unsigned char HDAE5000_RAM_FlsRecords[];
extern unsigned char HDAE5000_FlsItem_SongRecord_Str_Blank26[];

struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };

#define HD_TABLES ((unsigned char *)0x201632L)
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))

int HDAE5000_FlsItem_IsSet(unsigned int fls, unsigned int item)
{
    int r = 0;
    if (FLSB(16, fls, item) == 0 || FLSB(48, fls, item) == 0)
        r = -1;
    return r;
}

void HDAE5000_FlsItem_Get(unsigned int fls, unsigned int item, struct FlsItem *out)
{
    int r;
    r = HDAE5000_FlsItem_IsSet(fls, item);
    if (r == -1)
        return;
    out->dir = FLSB(16, fls, item) - 1;
    out->song = FLSB(48, fls, item) - 1;
    out->as = FLSB(80, fls, item);
    out->al = FLSB(112, fls, item);
}

void HDAE5000_FlsItem_SetAutoLoad(unsigned int fls, unsigned int item, unsigned char on)
{
    int r;
    r = HDAE5000_FlsItem_IsSet(fls, item);
    if (r == -1)
        return;
    FLSB(112, fls, item) = on;
}

void HDAE5000_FlsItem_SetAutoStart(unsigned int fls, unsigned int item, unsigned char on)
{
    int r;
    r = HDAE5000_FlsItem_IsSet(fls, item);
    if (r == -1)
        return;
    FLSB(80, fls, item) = on;
}

unsigned char *HDAE5000_FlsItem_SongRecord(unsigned int fls, unsigned int item)
{
    if (HDAE5000_FlsItem_IsSet(fls, item) != -1)
        return HD_TABLES + ((FLSB(48, fls, item) - 1) * 76 + ((unsigned long)(FLSB(16, fls, item) - 1) * 0x4c0 + 0x780));
    else
        return HDAE5000_FlsItem_SongRecord_Str_Blank26;
}
