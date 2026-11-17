/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_9a.c (2026-11-16-86-sub-r9)
   sha256 88eb9f6250e886eb73d0ea17657ceaba2c1d96ee178a9e302b394fec469d7fa4 (name+funcs); compiled at -Xr */
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
int TVF_Clamp_Cutoff(int a);
void TVF_Emit_Offset_Reg100(unsigned char *v)
{
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x40)
        ram_451d4 = ((*(int *)((v) + (66))) & 0xff80) | TVF_Clamp_Cutoff(((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x80) ?
                                                             ((*(int *)((v) + (66))) & 0x7f) - (char)(*(unsigned char **)((v) + (35)))[31] :
                                                             ((*(int *)((v) + (66))) & 0x7f) + (char)(*(unsigned char **)((v) + (35)))[31]);
    else ram_451d4 = (*(int *)((v) + (66)));
    ram_451d6 = (*(int *)((v) + (68)));
}
