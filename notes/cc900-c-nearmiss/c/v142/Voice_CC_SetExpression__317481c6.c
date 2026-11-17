/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_2a.c (2026-11-16-47-sub-r2)
   sha256 317481c6cc0b0362eb3d69ef64a520bc9035dd3312d59f39df1c5ca8e5f184c4 (name+funcs); compiled at -Xr */
extern unsigned int ram_41343;
extern unsigned char ram_41378[];
extern unsigned int Voice_CC_VolumeCurve[];
void Voice_CC_SetExpression(unsigned char part, unsigned char v)
{
    if (v != 0) {
        if (ram_41343 & 1) *(unsigned int *)&ram_41378[part * 0x11f] = Voice_CC_VolumeCurve[v];
        else if (ram_41343 & 2) *(unsigned int *)&ram_41378[part * 0x11f] = Voice_CC_VolumeCurve[v];
        else *(unsigned int *)&ram_41378[part * 0x11f] = v - 0x7f;
    } else *(unsigned int *)&ram_41378[part * 0x11f] = 0xfe00;
}
