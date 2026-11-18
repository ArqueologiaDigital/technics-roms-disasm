/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/ui_widget_defs_m0.c (2026-11-18-28-p6-r36)
   sha256 a245a0f8b3e34e4735387b551039b47fa453d7aca9759caca312cc5ff73fa19f (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern int DRAW_ENABLED;
extern int ram_30450;
extern void Gfx_BlitDirtyRegions(void);
void UpdateScreen_CheckDirty(void *q)
{
	Gfx_BlitDirtyRegions();
	if (ram_30450 == 0)
		DRAW_ENABLED = ram_30450;
}
