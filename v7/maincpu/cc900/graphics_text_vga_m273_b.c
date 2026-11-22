/* Functions of display/graphics_text_vga.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ColorBlit2 DrawBitmap_Impl DrawQueue_Alloc DrawRing_Post IS_XSP_INSIDE_4K_REGION_AT_1C032 */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rect { int x0, y0, x1, y1; };
struct rop { int code; struct rect r; };
extern unsigned int GFX_BG_COLOR;
extern void ColorBlit2(struct rect *r, int n);
extern void ColorBlit_ByteData(struct rop *p);

void ColorBlit_ByteData(struct rop *p)
{
	struct rect r;

	r.x0 = p->r.x0;
	r.y0 = p->r.y0;
	r.x1 = p->r.x1;
	r.y1 = p->r.y1;
	ColorBlit2(&r, GFX_BG_COLOR);
}

/* cc900-module: Display_DeferOrDrawWall_Code Display_DeferOrDrawWall_Direct Display_DeferOrUpdScreen_Code Display_DeferOrUpdScreen_Direct Display_DeferOrUpdateScreen_Direct DrawWall IsDrawTask SetNeedUpdate UpdateScreen */
struct wcmd { void (*fn)(struct wcmd *); };
extern int IsDrawTask(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern void Display_DeferOrUpdScreen_Direct(void);
extern void Display_DeferOrUpdScreen_Code(struct wcmd *q);
extern void Display_DeferOrUpdScreen_Direct(void);

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
/* cc900-name: Display_DeferOrUpdScreen_Code=Display_DeferOrUpdateScreen_Code */
/* cc900-name: Display_DeferOrUpdScreen_Direct=Display_DeferOrUpdateScreen_Direct */
void Display_DeferOrUpdateScreen(void)
{
	struct wcmd *q;

	if (IsDrawTask() == 0) {
		q = (struct wcmd *)DrawQueue_Alloc(sizeof(struct wcmd));
		q->fn = Display_DeferOrUpdScreen_Code;
		DrawRing_Post(q);
	} else
		Display_DeferOrUpdScreen_Direct();
}
