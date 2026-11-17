/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_12c.c (2026-11-16-97-sub-r12)
   sha256 80e89e45da7957e85d3cc4eae4c24f6bcebac276bf5c8c232e93add476a1829a (name+funcs); compiled at -Xr */
#define P(p, o) (*(unsigned char **)((p) + (o)))
int TVF_Set_Bypass(unsigned char *v);
int TVF_Build_Full(unsigned char *v);
int Voice_PitchPack_Mode2(unsigned char *v);
int Voice_PitchPack_Mode3(unsigned char *v);
int Voice_PitchPack_Mode4_Single(unsigned char *v);
void Voice_PitchPack_Mode5_Dual(unsigned char *v);
int TVF_Build_Dispatch(unsigned char *v)
{
    switch ((int)(P(v, 23)[54] & 7)) {
    default:
    case 0:
        return TVF_Set_Bypass(v);
    case 1:
        return TVF_Build_Full(v);
    case 2:
        return Voice_PitchPack_Mode2(v);
    case 3:
        return Voice_PitchPack_Mode3(v);
    case 4:
        return Voice_PitchPack_Mode4_Single(v);
    case 5:
        Voice_PitchPack_Mode5_Dual(v);
    }
    return 0;
}
