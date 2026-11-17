/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_4b.c (2026-11-16-62-sub-r4)
   sha256 2930891c0f4cc37037eb6f8318034f85e7213280edee0124175fee577eb1783d (name+funcs); compiled at -Xr */
extern unsigned char __near ram_24e6[];
void VoiceState_SwapSlot_DE_BC(unsigned char a, unsigned char c)
{
    unsigned char x, y;
    x = *(unsigned char *)((unsigned long)(ram_24e6 + (int)a * 12) + (unsigned int)c);
    y = *(unsigned char *)((unsigned long)(ram_24e6 + (int)a * 12) + ((unsigned int)c + 4));
    *(unsigned char *)((unsigned long)(ram_24e6 + (int)y * 12) + (unsigned int)c) = x;
    *(unsigned char *)((unsigned long)(ram_24e6 + (int)x * 12) + ((unsigned int)c + 4)) = y;
    *(unsigned char *)((unsigned long)(ram_24e6 + (int)a * 12) + (unsigned int)c) = a;
    *(unsigned char *)((unsigned long)(ram_24e6 + (int)a * 12) + ((unsigned int)c + 4)) = a;
}
