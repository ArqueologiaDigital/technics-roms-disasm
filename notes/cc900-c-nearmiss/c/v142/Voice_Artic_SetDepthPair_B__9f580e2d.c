/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w5a.c (2026-11-19-10-sub-r23w-asm)
   sha256 9f580e2d240854361aca295c79708c26ded3536f461a92b7ed539fefcce12719 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41474[];
extern unsigned char ram_41475[];
void Voice_Artic_SetDepthPair_B(unsigned char part, unsigned char v)
{
    ram_41474[part * 287] = ((char)v >> 4) << 2;
    ram_41475[part * 287] = ((char)(unsigned char)(v << 4) >> 4) << 3;
}
