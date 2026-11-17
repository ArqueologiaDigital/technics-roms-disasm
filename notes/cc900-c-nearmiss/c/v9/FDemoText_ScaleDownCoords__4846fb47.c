/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/fdemotext_routines_xr.c (2026-11-16-55-p6-r10)
   sha256 4846fb474ae04f6cf194f993e33c8a0a803a6b97f71c060bf1a6191260eac6b4 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
struct pt { int x, y; };
void FDemoText_ScaleDownCoords(struct pt *s, struct pt *d)
{
	d->x = s->x / 8;
	d->y = s->y / 4;
}
