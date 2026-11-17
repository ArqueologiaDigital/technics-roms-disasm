/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_flsitem_set.c (2026-11-16-85-hd-r18-ports)
   sha256 fdd6060821c74795b045f47dbc7f318d39b1b758d9feebf5deb3f932d6d29df8 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: FlsItemSetAS_u=HDAE5000_FlsItem_SetAutoStart */
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
int HDAE5000_FlsItem_IsSet(unsigned int fls, unsigned int item);
void FlsItemSetAS_u(unsigned int fls, register unsigned int item, unsigned char on)
{
    unsigned int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) == 0xffff)
        return;
    FLSB(80, fls, item) = on;
}
