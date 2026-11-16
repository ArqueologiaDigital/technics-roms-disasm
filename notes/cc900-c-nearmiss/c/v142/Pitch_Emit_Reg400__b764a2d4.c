/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_10c.c (2026-11-16-90-sub-r10)
   sha256 b764a2d4f2a686ba767b16d3e964743b67ea75bd744e3f4404b12656041742eb (name+funcs); compiled at -O3 -Xr */
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern int ram_41347;
extern int ram_4135a;
extern unsigned int ram_451da;
unsigned int Pitch_Saturate_15bit(unsigned int a);
void Pitch_Emit_Reg400(unsigned char *v)
{
    int d;
    d = SW(v, 10) + ram_41347;
    if (W(P(v, 39), 24) & 0x10) {
        if (W(P(v, 39), 24) & 0x20) d -= SW(P(v, 35), 29);
        else d += SW(P(v, 35), 29);
    }
    if (W(v, 1) & 0x400) d += ram_4135a;
    ram_451da = Pitch_Saturate_15bit(d);
}
