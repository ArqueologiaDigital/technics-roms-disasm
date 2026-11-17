/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17c.c (2026-11-16-126-sub-r17)
   sha256 bd67878aa1a0f366ab5645d3437f1f797cce2b2e9dbc7116c6bff2282d78e494 (name+funcs); compiled at -Xr */
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
int TVF_Clamp_Cutoff(int a);
void TVF_Emit_Offset_Reg100(unsigned char *v)
{
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x40)
        ram_451d4 = ((*(int *)((v) + (66))) & 0xff80) | TVF_Clamp_Cutoff(((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x80) ?
                                                             ((*(unsigned int *)((v) + (66))) & 0x7f) - (char)(*(unsigned char **)((v) + (35)))[31] :
                                                             ((*(unsigned int *)((v) + (66))) & 0x7f) + (char)(*(unsigned char **)((v) + (35)))[31]);
    else ram_451d4 = (*(int *)((v) + (66)));
    ram_451d6 = (*(int *)((v) + (68)));
}
