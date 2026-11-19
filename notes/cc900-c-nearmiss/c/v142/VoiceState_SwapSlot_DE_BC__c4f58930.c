/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w5b.c (2026-11-19-10-sub-r23w-asm)
   sha256 c4f58930b3bd612ce04c6acbf4749489c7f80f911867c569244db57c32d4251f (name+funcs); compiled at -Xr
   cc900-options: -Xr */
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
