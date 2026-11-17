/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_8a.c (2026-11-16-82-sub-r8)
   sha256 45988cee248268643a64a4f7c2c639e4eeefbcdc285480358c8ff1adf1d94b44 (name+funcs); compiled at -Xr
   cc900-name: Voice_Pitch_WriteOutReg_Sec=Voice_Pitch_WriteOutputReg_Secondary */
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned int ram_451da;
extern int ram_41347;
unsigned int Pitch_Saturate_15bit(unsigned int a);
void Voice_Pitch_WriteOutReg_Sec(unsigned char *v)
{
    int d;
    d = SW(v, 10) + ram_41347;
    if (W(P(v, 39), 24) & 0x10) {
        if (W(P(v, 39), 24) & 0x20) d -= SW(P(v, 35), 29);
        else d += SW(P(v, 35), 29);
    }
    ram_451da = Pitch_Saturate_15bit(d);
}
