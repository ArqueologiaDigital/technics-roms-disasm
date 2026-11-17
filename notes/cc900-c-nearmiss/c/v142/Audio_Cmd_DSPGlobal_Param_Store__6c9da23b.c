/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17a.c (2026-11-16-126-sub-r17)
   sha256 6c9da23be1740b125262337d35d6419d9e17f20c3d4204d47661ba77eaf9761b (name+funcs); compiled at -Xr */
extern unsigned char ram_44fce[];
void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m)
{
    unsigned char *p;
    p = (unsigned char *)((unsigned int *)(ram_44fce + ((int)((m[2] & 0xc0) >> 6) * 11 + 426)));
    p += m[2] & 0x3f;
    *p = m[4];
    if ((m[2] & 0x7f) <= 10) __ASM("");
}
