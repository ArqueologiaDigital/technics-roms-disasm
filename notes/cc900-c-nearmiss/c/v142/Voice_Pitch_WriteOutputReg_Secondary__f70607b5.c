/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_7a.c (2026-11-16-79-sub-r7)
   sha256 f70607b5111b1b73ae470351c728e34d55ce40ce7a9d878e58e34960dca5e443 (name+funcs); compiled at -Xr
   cc900-name: Voice_Pitch_WriteOutReg_Sec=Voice_Pitch_WriteOutputReg_Secondary */
extern unsigned int ram_451da;
extern int ram_41347;
unsigned int Pitch_Saturate_15bit(unsigned int a);
void Voice_Pitch_WriteOutReg_Sec(unsigned char *v)
{
    int d;
    d = (*(int *)((v) + (10))) + ram_41347;
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x10) {
        if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x20) d -= (*(int *)(((*(unsigned char **)((v) + (35)))) + (29)));
        else d += (*(int *)(((*(unsigned char **)((v) + (35)))) + (29)));
    }
    ram_451da = Pitch_Saturate_15bit(d);
}
