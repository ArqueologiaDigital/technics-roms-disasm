/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hd_r9_ng1b.c (2026-11-16-66-hd-r10)
   sha256 79b8f6042591ad27f4a659970d17a20f9ce920557afaef5a90cff1f9c1490b59 (tar-sha256); compiled at -Xr */
/* lane_hd round 9, helper h_near, form b: hd_r9_ng1.c's functions (same names) with these second forms:
   - Get: an int local and the cast around the assignment, (unsigned int)(r = IsSet()) != 0xffff;
   - SetAutoLoad / SetAutoStart: an unsigned local assigned from the int call (the conversion at the assignment)
     and compared as it is, r == 0xffff;
   - SongRecord: the song part as (int)(unsigned char)(byte - 1) * 76 and the result as a pointer plus the sum,
     DirNames + ((long)sofs + dir part), instead of the element address.
   IsSet unchanged (it matches). */

extern unsigned char HDAE5000_RAM_FlsRecords[];
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_FlsItem_SongRecord_Str_Blank26[];

struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };

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
    if ((unsigned int)(r = HDAE5000_FlsItem_IsSet(fls, item)) != 0xffff) {
        out->dir = (unsigned char)(FLSB(16, fls, item) - 1);
        out->song = (unsigned char)(FLSB(48, fls, item) - 1);
        out->as = FLSB(80, fls, item);
        out->al = FLSB(112, fls, item);
    }
}

void HDAE5000_FlsItem_SetAutoLoad(unsigned int fls, unsigned int item, unsigned char on)
{
    unsigned int r;
    r = HDAE5000_FlsItem_IsSet(fls, item);
    if (r == 0xffff)
        return;
    FLSB(112, fls, item) = on;
}

void HDAE5000_FlsItem_SetAutoStart(unsigned int fls, unsigned int item, unsigned char on)
{
    unsigned int r;
    r = HDAE5000_FlsItem_IsSet(fls, item);
    if (r == 0xffff)
        return;
    FLSB(80, fls, item) = on;
}

unsigned char *HDAE5000_FlsItem_SongRecord(unsigned int fls, unsigned int item)
{
    int r;
    int sofs;
    r = HDAE5000_FlsItem_IsSet(fls, item);
    if (r != -1) {
        sofs = (int)(unsigned char)(FLSB(48, fls, item) - 1) * 76;
        return HDAE5000_RAM_DirNames + ((long)sofs + ((unsigned long)(unsigned char)(FLSB(16, fls, item) - 1) * 0x4c0 + 0x780));
    } else
        return HDAE5000_FlsItem_SongRecord_Str_Blank26;
}
