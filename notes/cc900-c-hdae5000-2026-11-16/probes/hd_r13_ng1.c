/* lane_hd round 13, helper h_near2, form a: the FLS item accessors HDAE5000_FlsItem_SongRecord, _IsSet, _Get,
   _SetAutoStart, _SetAutoLoad (one calr group), now in ROM address order (hd_r9_ng1.c had SongRecord last and
   SetAutoLoad before SetAutoStart), from hd_r9_ng1.c, with variants under cc900-name aliases.  Options: -Xr.
   cc900-module: HDAE5000_FlsItem_IsSet
   FLS record (HDAE5000_RAM_FlsRecords, 120 x 144 B): 16-byte name, then four 32-byte item columns at +16 (dir + 1,
   0 = free), +48 (song + 1), +80 (AS), +112 (AL); item fields through run 52's integer-address idiom.
   What is left (runs 57 and 66) is the register choice at entry, nothing else:
   - Get / SetAuto* / SongRecord: the ROM keeps item in IZ and fls on the stack (`ld iz,bc; ld (xsp+N),wa`), and the
     IsSet result in WA (`ld wa,hl; cp wa,0xffff`).  fls and item are used equally often, and V4.23 picks IZ for
     one or the other depending on unrelated parts of the function (Get: run 57 g1b item, run 66 ng1 fls, after only
     the field casts were added; SetAutoLoad: run 57 item, run 66 fls, after only `r == -1` became
     `(unsigned int)r == 0xffff`): a tie.  The result goes to WA only when it is assigned inside the test (ng1 Get,
     micro ae_i_call), and then V4.23 happened to give fls IZ.  Run 66's bodies are otherwise the ROM's.
     This form declares item `register`, in case an explicit register variable is served first; the main names
     keep run 66's best test (Get: unsigned r assigned in the test; SetAuto*: int r assigned in the test,
     `== -1`), and the _i / _u variants the other result type.  Form b (hd_r13_ng1b.c) tries K&R definitions with
     item declared before fls instead (the order in which the tie may be broken).
   - SongRecord (+3, not in this round's list, same cause): register item as well; body unchanged.
   IsSet matches (unchanged).
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

unsigned char *HDAE5000_FlsItem_SongRecord(unsigned int fls, register unsigned int item)
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

void HDAE5000_FlsItem_Get(unsigned int fls, register unsigned int item, struct FlsItem *out)
{
    unsigned int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) != 0xffff) {
        out->dir = (unsigned char)(FLSB(16, fls, item) - 1);
        out->song = (unsigned char)(FLSB(48, fls, item) - 1);
        out->as = FLSB(80, fls, item);
        out->al = FLSB(112, fls, item);
    }
}

void FlsItemGet_i(unsigned int fls, register unsigned int item, struct FlsItem *out)
{
    int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) != -1) {
        out->dir = (unsigned char)(FLSB(16, fls, item) - 1);
        out->song = (unsigned char)(FLSB(48, fls, item) - 1);
        out->as = FLSB(80, fls, item);
        out->al = FLSB(112, fls, item);
    }
}

void HDAE5000_FlsItem_SetAutoStart(unsigned int fls, register unsigned int item, unsigned char on)
{
    int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) == -1)
        return;
    FLSB(80, fls, item) = on;
}

void FlsItemSetAS_u(unsigned int fls, register unsigned int item, unsigned char on)
{
    unsigned int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) == 0xffff)
        return;
    FLSB(80, fls, item) = on;
}

void HDAE5000_FlsItem_SetAutoLoad(unsigned int fls, register unsigned int item, unsigned char on)
{
    int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) == -1)
        return;
    FLSB(112, fls, item) = on;
}

void FlsItemSetAL_u(unsigned int fls, register unsigned int item, unsigned char on)
{
    unsigned int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) == 0xffff)
        return;
    FLSB(112, fls, item) = on;
}
