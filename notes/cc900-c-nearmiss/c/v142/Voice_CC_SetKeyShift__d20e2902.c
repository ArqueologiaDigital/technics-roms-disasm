/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w3b.c (2026-11-19-10-sub-r23w-asm)
   sha256 d20e29023118a40f2a271ad82f83ef4675b92a35036e76a09e526311c9db51e7 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4137e[];
void Voice_CC_SetKeyShift(unsigned char part, unsigned char v)
{
    char t;
    t = v - 0x40;
    ram_4137e[part * 0x11f] = t;
}
