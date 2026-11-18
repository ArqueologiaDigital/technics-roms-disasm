/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_1m273b.c (2026-11-18-12-p6-r35)
   sha256 609aa860dafa55d0054032d8040501bfeacaf6f522408b994773e0ec4fdeb5b1 (tar-sha256); compiled at -O3 -XS -Xr */
extern int DRAW_ENABLED;
extern int ram_30450;
extern void Gfx_BlitDirtyRegions(void);
void UpdateScreen_CheckDirty(void *q)
{
	Gfx_BlitDirtyRegions();
	if (ram_30450 == 0)
		DRAW_ENABLED = ram_30450;
}
