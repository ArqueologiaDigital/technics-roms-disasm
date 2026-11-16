/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_3b.c (2026-11-16-58-sub-r3)
   sha256 37c0af016e565fee335c95be3cff7bb8f759446ff2d97b97f7bdcedab76f9756 (name+funcs); compiled at -Xr */
extern unsigned char ram_4137e[];
void Voice_CC_SetKeyShift(unsigned char part, unsigned char v)
{
    char t;
    t = v - 0x40;
    ram_4137e[part * 0x11f] = t;
}
