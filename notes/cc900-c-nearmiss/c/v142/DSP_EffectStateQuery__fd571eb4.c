/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_2b.c (2026-11-16-47-sub-r2)
   sha256 fd571eb4a11710ee3f94b685837fcd101aa3642b5af3b15ed9bdb7a9eba8f3f4 (name+funcs); compiled at -O3 -Xr */
extern unsigned char ram_41368[];
#define PART_FLAGS(p)   (((unsigned int *)(ram_41368 + (p) * 0x11f))[0])
int DSP_EffectStateQuery(unsigned char part, unsigned char *out)
{
    if ((PART_FLAGS(part) & 1) != 0) {
        *out = 1;
    } else {
        *out = 0;
    }
    return 1;
}
