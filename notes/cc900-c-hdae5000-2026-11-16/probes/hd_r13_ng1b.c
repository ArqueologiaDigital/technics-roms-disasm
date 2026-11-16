/* lane_hd round 13, helper h_near2, form b: hd_r13_ng1.c's functions (same names, ROM address order) with K&R
   definitions for SongRecord, Get, SetAutoStart and SetAutoLoad whose parameter declarations name item BEFORE fls.
   Options: -Xr.
   cc900-module: HDAE5000_FlsItem_IsSet
   Why: fls and item tie for IZ (see hd_r13_ng1.c); with prototype definitions V4.23 most often serves fls (the
   first parameter) first, and FlsItem_Set (hd_r13_ng2.c) shows the same preference.  If the tie is broken by the
   order of the parameters' declarations, an old-style definition can declare item first without changing the
   registers the arguments arrive in.  Old-style definitions take a char parameter in the byte register where the
   caller loads the word (brief: helper h_lyr), which is the ROM's `ld (xsp+2),e` for on.  No `register` here.
   IsSet (matches) keeps its prototype definition.  Variants as in form a.
   cc900-name: FlsItemGet_i=HDAE5000_FlsItem_Get
   cc900-name: FlsItemSetAS_u=HDAE5000_FlsItem_SetAutoStart
   cc900-name: FlsItemSetAL_u=HDAE5000_FlsItem_SetAutoLoad
*/

extern unsigned char HDAE5000_RAM_FlsRecords[];
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_FlsItem_SongRecord_Str_Blank26[];

struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };

#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))

int HDAE5000_FlsItem_IsSet(unsigned int fls, unsigned int item);

unsigned char *HDAE5000_FlsItem_SongRecord(fls, item)
unsigned int item;
unsigned int fls;
{
    int r;
    int sofs;
    r = HDAE5000_FlsItem_IsSet(fls, item);
    if (r != -1) {
        sofs = (int)(FLSB(48, fls, item) - 1) * 76;
        return &HDAE5000_RAM_DirNames[(long)sofs + ((unsigned long)(unsigned char)(FLSB(16, fls, item) - 1) * 0x4c0 + 0x780)];
    } else
        return HDAE5000_FlsItem_SongRecord_Str_Blank26;
}

int HDAE5000_FlsItem_IsSet(unsigned int fls, unsigned int item)
{
    int r = 0;
    if (FLSB(16, fls, item) == 0 || FLSB(48, fls, item) == 0)
        r = -1;
    return r;
}

void HDAE5000_FlsItem_Get(fls, item, out)
unsigned int item;
unsigned int fls;
struct FlsItem *out;
{
    unsigned int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) != 0xffff) {
        out->dir = (unsigned char)(FLSB(16, fls, item) - 1);
        out->song = (unsigned char)(FLSB(48, fls, item) - 1);
        out->as = FLSB(80, fls, item);
        out->al = FLSB(112, fls, item);
    }
}

void FlsItemGet_i(fls, item, out)
unsigned int item;
unsigned int fls;
struct FlsItem *out;
{
    int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) != -1) {
        out->dir = (unsigned char)(FLSB(16, fls, item) - 1);
        out->song = (unsigned char)(FLSB(48, fls, item) - 1);
        out->as = FLSB(80, fls, item);
        out->al = FLSB(112, fls, item);
    }
}

void HDAE5000_FlsItem_SetAutoStart(fls, item, on)
unsigned int item;
unsigned int fls;
unsigned char on;
{
    int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) == -1)
        return;
    FLSB(80, fls, item) = on;
}

void FlsItemSetAS_u(fls, item, on)
unsigned int item;
unsigned int fls;
unsigned char on;
{
    unsigned int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) == 0xffff)
        return;
    FLSB(80, fls, item) = on;
}

void HDAE5000_FlsItem_SetAutoLoad(fls, item, on)
unsigned int item;
unsigned int fls;
unsigned char on;
{
    int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) == -1)
        return;
    FLSB(112, fls, item) = on;
}

void FlsItemSetAL_u(fls, item, on)
unsigned int item;
unsigned int fls;
unsigned char on;
{
    unsigned int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) == 0xffff)
        return;
    FLSB(112, fls, item) = on;
}
