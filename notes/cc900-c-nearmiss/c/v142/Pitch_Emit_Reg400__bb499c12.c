/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_10a.c (2026-11-16-90-sub-r10)
   sha256 bb499c121aaefa01b0c094dc81af9c38404b55775ff87425d47cbe4ef107bd5d (name+funcs); compiled at -O3 -Xr */
extern int ram_41347;
extern int ram_4135a;
extern unsigned int ram_451da;
unsigned int Pitch_Saturate_15bit(unsigned int a);
void Pitch_Emit_Reg400(unsigned char *v)
{
    int d;
    d = (*(int *)((v) + (10))) + ram_41347;
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x10) {
        if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x20) d -= (*(int *)(((*(unsigned char **)((v) + (35)))) + (29)));
        else d += (*(int *)(((*(unsigned char **)((v) + (35)))) + (29)));
    }
    if ((*(unsigned int *)((v) + (1))) & 0x400) d += ram_4135a;
    ram_451da = Pitch_Saturate_15bit(d);
}
