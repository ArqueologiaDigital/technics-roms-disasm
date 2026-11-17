/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2a.c (2026-11-16-47-sub-r2)
   sha256 53d7a593968fb87f84af530bceae3e1c306174f47db7d2c6980e60b72454f307 (name+funcs); compiled at -Xr */
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern int __near ram_293e;
extern int ram_451ce;
void WaveSel_Emit_ZoneRecord_S4(unsigned char *v, unsigned char *t, unsigned char i)
{
    t += i * 4;
    P(v, 15) = t;
    ram_451ce = SW(t, 0);
    ram_293e = 0;
}
