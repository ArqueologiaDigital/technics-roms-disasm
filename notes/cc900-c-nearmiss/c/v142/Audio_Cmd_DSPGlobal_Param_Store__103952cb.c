/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17b.c (2026-11-16-126-sub-r17)
   sha256 103952cb479afdc1c60db40fc3853c5ae181d89a51e462c0596d12a2a476ff39 (name+funcs); compiled at -Xr */
extern unsigned char ram_44fce[];
void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m)
{
    unsigned char *p;
    p = (unsigned char *)((unsigned int *)(ram_44fce + (long)((int)((m[2] & 0xc0) >> 6) * 11 + 426)));
    p[m[2] & 0x3f] = m[4];
    if ((m[2] & 0x7f) <= 10) __ASM("");
}
