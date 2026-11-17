/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_U_18c.c (2026-11-17-7-sub-r18)
   sha256 6ca4f2a638402ffcdcd5926c1261daf0d719a4be06e9987d078f0b31724cd5cc (name+funcs); compiled at -Xr */
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
        if (W(P(v, 39), 24) & 0x80) d = (int)((W(v, 66) & 0x7f) - (char)P(v, 35)[31]);
        else d = (int)((W(v, 66) & 0x7f) + (char)P(v, 35)[31]);
        ram_451d4 = (SW(v, 66) & 0xff80) | (d = TVF_Clamp_Cutoff(d));
        ram_451d6 = (SW(v, 68) & 0xff80) | d;
    } else {
        ram_451d4 = SW(v, 66);
        ram_451d6 = SW(v, 68);
    }
}
