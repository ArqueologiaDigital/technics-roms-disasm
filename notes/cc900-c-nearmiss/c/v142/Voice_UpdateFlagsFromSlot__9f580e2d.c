/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w5a.c (2026-11-19-10-sub-r23w-asm)
   sha256 9f580e2d240854361aca295c79708c26ded3536f461a92b7ed539fefcce12719 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
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
