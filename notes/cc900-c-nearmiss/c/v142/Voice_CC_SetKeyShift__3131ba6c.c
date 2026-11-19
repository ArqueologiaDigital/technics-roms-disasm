/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w3a.c (2026-11-19-10-sub-r23w-asm)
   sha256 3131ba6ce52619a70fd697c12df6ce15b0df07ab4801545fe99e86ef6e816881 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4137e[];
void Voice_CC_SetKeyShift(unsigned char part, unsigned char v)
{
    char t;
    t = v - 0x40;
    ram_4137e[part * 0x11f] = t;
}
