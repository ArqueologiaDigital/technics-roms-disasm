/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2c.c (2026-11-16-47-sub-r2)
   sha256 675d49d3eeeea79e327148ffdc5c5179606a08452f10204af09a37e964ae4c72 (name+funcs); compiled at -Xr */
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern int __near ram_293e;
extern int ram_451ce;
void WaveSel_Emit_ZoneRecord_S13(unsigned char *v, unsigned char *t, unsigned char i)
{
    t += i * 13;
    P(v, 15) = t;
    W(v, 1) |= 0x3000;
    ram_451ce = SW(t, 0);
    ram_293e = 0;
}
