/* hdae5000_v1_15i: the functions of hdae5000/cc900-staged/hdae5000_flsitem_set.c that V4.23 reproduces unchanged in HD-AE5000 v1.15i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_flsitem_set.c.
   cc900-options: -Xr
   cc900-name: FlsItemSetAS_u=HDAE5000_FlsItem_SetAutoStart
   cc900-name: FlsItemSetAL_u=HDAE5000_FlsItem_SetAutoLoad
   cc900-module: HDAE5000_FlsItem_IsSet
*/
extern unsigned char HDAE5000_RAM_FlsRecords[];
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_FlsItem_SongRecord_Str_Blank26[];

struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };

#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))

int HDAE5000_FlsItem_IsSet(unsigned int fls, unsigned int item);

void FlsItemSetAS_u(unsigned int fls, register unsigned int item, unsigned char on)
{
    unsigned int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) == 0xffff)
        return;
    FLSB(80, fls, item) = on;
}

void FlsItemSetAL_u(unsigned int fls, register unsigned int item, unsigned char on)
{
    unsigned int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) == 0xffff)
        return;
    FLSB(112, fls, item) = on;
}
