/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_4c.c (2026-11-16-62-sub-r4)
   sha256 5fa07bbc698c05cdf1499ef39438f01891abf5d3f8e20a0d5e7cd774bd8f0d32 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
void Voice_UpdateFlagsFromSlot(unsigned char part)
{
    unsigned int *q, *f;
    q = (unsigned int *)((unsigned long)&ram_41368[part * 287] + 258);
    f = (unsigned int *)(ram_41368 + part * 287) + 1;
    if (q[0] != 0) *f |= 1; else *f &= ~1;
    if (q[1] != 0) *f |= 2; else *f &= ~2;
    if (q[2] != 0) *f |= 4; else *f &= ~4;
    if (q[3] != 0) *f |= 8; else *f &= ~8;
}
