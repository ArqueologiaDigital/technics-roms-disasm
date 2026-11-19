/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hdae5000_hd_driver__typesel_buildmask_r72.c (2026-11-19-61-hd-r73-staged)
   sha256 47058081694a614ffacfff5a5abac59ef6788e392b82dc3dc328b9af550cfcaa (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
}
