/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_window_procs_m0_xr.c (2026-11-18-28-p6-r36)
   sha256 bef64c7f8113fac23c2a4dbb9ad7c35fdbb98b51f90b9f01d1f666a4b0467cb4 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct pt { int x, y; };
struct cmd_pt_i { void *fn; struct pt p; int n; };
extern void ClipBlit_Replace_Impl(struct pt *, int);
void ClipBlit_Replace_ParamBlock(struct cmd_pt_i *q)
{
	ClipBlit_Replace_Impl(&q->p, q->n);
}
