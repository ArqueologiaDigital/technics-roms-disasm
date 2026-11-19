/* Functions of hdae5000_hd_driver.s.  (hdae5000_hd_driver__typesel_buildmask_r72.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_hd_driver__typesel_buildmask_r72.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
*/
struct TypeSel { unsigned int mask; unsigned char flag[10]; };

/* v1.15i: eight song parts, so no flag[8] / bit 0x100 */
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
}
