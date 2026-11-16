/* lane_hd round 9, helper h_near, form a: the FLS item accessors HDAE5000_FlsItem_IsSet, _Get, _SetAutoLoad,
   _SetAutoStart, _SongRecord (one calr group, ROM address order), from hd_r4_g1.c / hd_r4_g1b.c.  Options: -Xr.
   FLS record (HDAE5000_RAM_FlsRecords, 120 x 144 B): 16-byte name, then four 32-byte item columns at +16 (dir + 1,
   0 = free), +48 (song + 1), +80 (AS), +112 (AL); item fields through run 52's integer-address idiom.
   Run 2026-11-16-57 showed two things to fix, the IZ choice and the compare after IsSet:
   - IZ: V4.23 gave the ROM's `ld iz,bc` (item in IZ, fls on the stack) for Get in form b and SetAuto* in form a,
     and `ld iz,wa` in the other forms: each function keeps the body that got IZ right;
   - the ROM moves IsSet's result to WA before comparing (`ld wa,hl; cp wa,0xffff`), a conversion: IsSet returns
     int (form a's IsSet, which matched) and the callers read it as unsigned int, Get through its unsigned local
     (`(r = IsSet()) != 0xffff`, as in g1b), SetAuto* through a cast of their int local;
   - SongRecord: compares HL directly (`cp hl,0xffff`), so its local is an int; song * 76 is an int local (the ROM's
     slot at xsp+2, `dec 1,a; extz wa; muls wa,76`: the byte - 1 widened by a cast, then a signed multiply; g1b's
     (unsigned char) cast made V4.23 multiply in byte width); the sum keeps the song part in WA ((long)sofs, the
     ROM's `ld wa,(xsp+2); exts xwa; add xwa,xhl`), and the table base comes last as the element address
     &DirNames[sum] (the ROM's `ld xhl,DirNames; add xhl,xwa`). */

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
    int r;
    r = HDAE5000_FlsItem_IsSet(fls, item);
    if ((unsigned int)r == 0xffff)
        return;
    FLSB(112, fls, item) = on;
}

void HDAE5000_FlsItem_SetAutoStart(unsigned int fls, unsigned int item, unsigned char on)
{
    int r;
    r = HDAE5000_FlsItem_IsSet(fls, item);
    if ((unsigned int)r == 0xffff)
        return;
    FLSB(80, fls, item) = on;
}

unsigned char *HDAE5000_FlsItem_SongRecord(unsigned int fls, unsigned int item)
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
