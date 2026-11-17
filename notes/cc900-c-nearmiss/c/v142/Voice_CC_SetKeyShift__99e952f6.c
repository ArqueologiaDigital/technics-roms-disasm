/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_3a.c (2026-11-16-58-sub-r3)
   sha256 99e952f60a590931da21e8c6184efc818dce0d30099b96db61b5a5c174d03956 (name+funcs); compiled at -Xr */
extern unsigned char ram_4137e[];
void Voice_CC_SetKeyShift(unsigned char part, unsigned char v)
{
    unsigned char t;
    t = v - 0x40;
    ram_4137e[part * 0x11f] = t;
}
