/* Functions of hdae5000_hd_driver.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions'
   ROM bytes (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); the build does not compile the HD-AE5000 trees yet.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   cc900-options: -Xr
*/

struct TypeSel { unsigned int mask; unsigned char flag[10]; };

void HDAE5000_TypeSel_BuildMask(struct TypeSel *r)
{
    r->mask = 0;
    if (r->flag[0] == 2) r->mask = 1;
    if (r->flag[1] == 2) r->mask |= 2;
    if (r->flag[2] == 2) r->mask |= 4;
    if (r->flag[3] == 2) r->mask |= 8;
    if (r->flag[4] == 2) r->mask |= 0x10;
    if (r->flag[5] == 2) r->mask |= 0x20;
    if (r->flag[6] == 2) r->mask |= 0x40;
    if (r->flag[7] == 2) r->mask |= 0x80;
    if (r->flag[8] == 2) r->mask |= 0x100;
}
