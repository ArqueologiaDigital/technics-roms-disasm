/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_1m273b.c (2026-11-18-12-p6-r35)
   sha256 609aa860dafa55d0054032d8040501bfeacaf6f522408b994773e0ec4fdeb5b1 (tar-sha256); compiled at -Xr */
struct pt { int x, y; };
struct cmd_pt_i { void *fn; struct pt p; int n; };
extern void ClipBlit_Replace_Impl(struct pt *, int);
void ClipBlit_Replace_ParamBlock(struct cmd_pt_i *q)
{
	ClipBlit_Replace_Impl(&q->p, q->n);
}
