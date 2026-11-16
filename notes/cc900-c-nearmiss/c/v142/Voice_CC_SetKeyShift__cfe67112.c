/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_4a.c (2026-11-16-62-sub-r4)
   sha256 cfe67112eee206777802505b2205c972ef04a082c287e343a6fea5470e9fc387 (name+funcs); compiled at -Xr */
extern unsigned char ram_4137e[];
void Voice_CC_SetKeyShift(unsigned char part, unsigned char v)
{
    unsigned char t;
    t = v;
    t -= 0x40;
    ram_4137e[part * 0x11f] = t;
}
