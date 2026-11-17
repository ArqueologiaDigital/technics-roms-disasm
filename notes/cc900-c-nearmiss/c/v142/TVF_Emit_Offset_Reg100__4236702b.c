/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17a.c (2026-11-16-126-sub-r17)
   sha256 4236702b3d6d2cd4a34bd2c4b4787b866c2680f5404a1df78ec1c7768ec2066d (name+funcs); compiled at -Xr */
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
int TVF_Clamp_Cutoff(int a);
void TVF_Emit_Offset_Reg100(unsigned char *v)
{
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x40)
        ram_451d4 = ((*(int *)((v) + (66))) & 0xff80) | TVF_Clamp_Cutoff(((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x80) ?
                                                             (int)(((*(unsigned int *)((v) + (66))) & 0x7f) - (char)(*(unsigned char **)((v) + (35)))[31]) :
                                                             (int)(((*(unsigned int *)((v) + (66))) & 0x7f) + (char)(*(unsigned char **)((v) + (35)))[31]));
    else ram_451d4 = (*(int *)((v) + (66)));
    ram_451d6 = (*(int *)((v) + (68)));
}
