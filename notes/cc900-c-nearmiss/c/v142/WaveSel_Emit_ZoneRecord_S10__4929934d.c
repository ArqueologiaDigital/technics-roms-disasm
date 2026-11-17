/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2b.c (2026-11-16-47-sub-r2)
   sha256 4929934d1be3b922f61146a30935689ade1baf0354878540871355a4884bb871 (name+funcs); compiled at -Xr */
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern int __near ram_293e;
extern int ram_451ce;
void WaveSel_Emit_ZoneRecord_S10(unsigned char *v, unsigned char *t, unsigned char i)
{
    t = &t[i * 10];
    P(v, 15) = t;
    W(v, 1) |= 0x1000;
    ram_451ce = SW(t, 0);
    ram_293e = 0;
}
