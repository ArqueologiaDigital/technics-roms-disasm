/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17c.c (2026-11-16-126-sub-r17)
   sha256 cb8d8be11508728097d9e78ae3bf4fbe5f7b1c76f6a92dd24928a8442d7e7268 (name+funcs); compiled at -Xr */
extern unsigned char ram_44fce[];
void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m)
{
    ((unsigned char *)((unsigned int *)&ram_44fce[(int)(unsigned int)((int)((m[2] & 0xc0) >> 6) * 11 + 426)]))[m[2] & 0x3f] = m[4];
    if ((m[2] & 0x7f) <= 10) __ASM("");
}
