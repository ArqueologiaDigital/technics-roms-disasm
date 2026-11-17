/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_8c.c (2026-11-16-82-sub-r8)
   sha256 8425d89435501285c5621aa4eb0c72cc6c86af1f723686ae88429516fe20ee43 (name+funcs); compiled at -Xr */
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
int TVF_Clamp_Cutoff(int a);
void TVF_Emit_Offset_Both(unsigned char *v)
{
    int d;
    if (W(P(v, 39), 24) & 0x40) {
        d = TVF_Clamp_Cutoff((W(P(v, 39), 24) & 0x80) ? (SW(v, 66) & 0x7f) - (char)P(v, 35)[31] :
                                                       (SW(v, 66) & 0x7f) + (char)P(v, 35)[31]);
        ram_451d4 = (SW(v, 66) & 0xff80) | d;
        ram_451d6 = (SW(v, 68) & 0xff80) | d;
    } else {
        ram_451d4 = SW(v, 66);
        ram_451d6 = SW(v, 68);
    }
}
