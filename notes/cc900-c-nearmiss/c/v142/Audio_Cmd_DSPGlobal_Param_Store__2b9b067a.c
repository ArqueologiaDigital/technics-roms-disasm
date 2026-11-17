/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18b.c (2026-11-17-7-sub-r18)
   sha256 2b9b067aa3f5d6c5692fafb23e49ef5089f738ea67d405a1f19b2166fe4e7881 (name+funcs); compiled at -Xr */
extern unsigned char ram_44fce[];
#define EDIT_AT(i) (&ram_44fce[(int)(unsigned int)(i)])
void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m)
{
    unsigned char *p;

    p = EDIT_AT((int)((m[2] & 0xc0) >> 6) * 11 + 426);
    p += m[2] & 0x3f;
    *p = m[4];
    if ((m[2] & 0x7f) <= 10) __ASM("");
}
