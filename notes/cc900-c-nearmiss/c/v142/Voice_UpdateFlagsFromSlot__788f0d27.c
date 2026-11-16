/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3b.c (2026-11-16-58-sub-r3)
   sha256 788f0d271359aef4ace536ce58c994c054403ce241712b29d2f7e0b99f5470cf (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
void Voice_UpdateFlagsFromSlot(unsigned char part)
{
    unsigned int *q, *f;
    q = (unsigned int *)(&ram_41368[part * 287] + 258);
    f = (unsigned int *)(ram_41368 + part * 287 + 2);
    if (q[0] != 0) *f |= 1; else *f &= ~1;
    if (q[1] != 0) *f |= 2; else *f &= ~2;
    if (q[2] != 0) *f |= 4; else *f &= ~4;
    if (q[3] != 0) *f |= 8; else *f &= ~8;
}
