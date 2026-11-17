/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17a.c (2026-11-16-126-sub-r17)
   sha256 4236702b3d6d2cd4a34bd2c4b4787b866c2680f5404a1df78ec1c7768ec2066d (name+funcs); compiled at -Xr */
int TVF_Set_Bypass(unsigned char *v);
int TVF_Build_Full(unsigned char *v);
int Voice_PitchPack_Mode2(unsigned char *v);
int Voice_PitchPack_Mode3(unsigned char *v);
int Voice_PitchPack_Mode4_Single(unsigned char *v);
void Voice_PitchPack_Mode5_Dual(unsigned char *v);
int TVF_Build_Dispatch(unsigned char *v)
{
    switch ((*(unsigned char **)((v) + (23)))[54] & 7) {
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
        break;
    }
}
