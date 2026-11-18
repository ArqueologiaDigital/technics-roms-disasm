/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ClipBlit_Replace_Impl ColorBlit2_Impl DrawBitmapSPFast_Impl DrawDesignBox_Impl DrawDottedLineWithMode_Impl DrawFrame_Impl DrawIcons_Impl DrawQueue_Alloc DrawRing_Post Gfx_BlitDirtyRegions IS_XSP_INSIDE_4K_REGION_AT_1C032 */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
extern int ram_30450;
extern void Gfx_BlitDirtyRegions(void);
extern void UpdateScreen_CheckDirty(void *q);
extern void UpdateScreen(void);

/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
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
