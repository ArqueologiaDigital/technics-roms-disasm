/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/ui_widget_defs_m273.c (2026-11-18-28-p6-r36)
   sha256 d210ad5493c7e731fe3abe7c78d3f00c841a665c5908230ea3dab395338ebd74 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
extern int ram_30450;
extern void Gfx_BlitDirtyRegions(void);
extern void UpdateScreen_CheckDirty(void *q);
void UpdateScreen(void)
{
	void **q;

	if (IsXspInDrawStack() != 0) {
		Gfx_BlitDirtyRegions();
		if (ram_30450 == 0)
			DRAW_ENABLED = ram_30450;
	} else {
		q = (void **)DrawQueue_Alloc(4);
		*q = (void *)UpdateScreen_CheckDirty;
		DrawRing_Post(q);
	}
}
