/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/graphics_text_vga_m273.c (2026-11-22-6-p6-r73)
   sha256 669554da9e0a9d7a747fb83ae10461abf0a5d18bc279b966360cc4f0610b1322 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: Display_FillPalBandFromEnt_Impl=Display_FillPaletteBandFromEntry_Impl
   cc900-name: Display_FillPalBandFromEntry=Display_FillPaletteBandFromEntry
   cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct icmd { void (*fn)(struct icmd *); unsigned int w; };
extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern void Display_FillPalBandFromEnt_Impl(unsigned int);
void GraphicsRender_ByteData_Code(struct icmd *q);
extern void GraphicsRender_ByteData_Code(struct icmd *q);
void Display_FillPalBandFromEntry(unsigned int w)
{
	struct icmd *q;

	if (IsXspInDrawStack() != 0)
		Display_FillPalBandFromEnt_Impl(w);
	else {
		q = (struct icmd *)DrawQueue_Alloc(6);
		q->fn = GraphicsRender_ByteData_Code;
		q->w = w;
		DrawRing_Post(q);
	}
}
