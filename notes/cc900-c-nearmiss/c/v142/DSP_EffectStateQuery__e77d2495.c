/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_2a.c (2026-11-16-47-sub-r2)
   sha256 e77d2495b549821b0ba06f8b78d5c1927c12696a39635b76364de81b0b34400e (name+funcs); compiled at -O3 -Xr */
extern unsigned char ram_41368[];
#define PART_FLAGS(p)   (*(unsigned int *)(ram_41368 + (p) * 0x11f))
int DSP_EffectStateQuery(unsigned char part, unsigned char *out)
{
    if (PART_FLAGS(part) & 1) *out = 1;
    else *out = 0;
    return 1;
}
