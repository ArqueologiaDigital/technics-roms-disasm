/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_U_18a.c (2026-11-17-7-sub-r18)
   sha256 28995d12564daee79c182a1ebc86ab804043dda38b11687ee466a817e53c36e2 (name+funcs); compiled at -Xr */
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
int TVF_Clamp_Cutoff(int a);
void TVF_Emit_Offset_Both(unsigned char *v)
{
    unsigned int d;
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x40) {
        if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x80) d = ((*(int *)((v) + (66))) & 0x7f) - (char)(*(unsigned char **)((v) + (35)))[31];
        else d = ((*(int *)((v) + (66))) & 0x7f) + (char)(*(unsigned char **)((v) + (35)))[31];
        ram_451d4 = ((*(unsigned int *)((v) + (66))) & 0xff80) | (d = TVF_Clamp_Cutoff(d));
        ram_451d6 = ((*(unsigned int *)((v) + (68))) & 0xff80) | d;
    } else {
        ram_451d4 = (*(int *)((v) + (66)));
        ram_451d6 = (*(int *)((v) + (68)));
    }
}
