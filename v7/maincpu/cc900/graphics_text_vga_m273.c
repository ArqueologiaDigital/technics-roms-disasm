/* Functions of display/graphics_text_vga.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawDottedLineWithMode DrawLineWithMode DrawRect */   /* scripts/analysis/cc900/module_calls.py v10 */

struct dsrc { unsigned char op[2]; int a2; int a4; int a6; int a8; };
struct rect { int x0; int y0; int x1; int y1; };
extern int GFX_FG_COLOR;
extern void DrawRect(struct rect *, int);
extern void SeGfx_StaticOp09_Box(struct dsrc *s);

void SeGfx_StaticOp09_Box(struct dsrc *s)
{
    struct rect r;
    r.x0 = s->a2;
    r.y0 = s->a4;
    r.x1 = s->a6;
    r.y1 = s->a8;
    DrawRect(&r, GFX_FG_COLOR);
}

/* cc900-module: ColorBlit2_LargeCodeBlock */
struct pt { int x; int y; };
extern void DrawLineWithMode(struct pt *, struct pt *, int);
extern void SeGfx_StaticOp00_Line(struct dsrc *s);
extern void SeGfx_StaticOp02_Line(struct dsrc *s);
extern void DrawDottedLineWithMode(struct pt *, struct pt *, int);
extern void SeGfx_StaticOp15_DottedLine(struct dsrc *s);

void SeGfx_StaticOp00_Line(struct dsrc *s)
{
    struct pt a, b;
    a.x = s->a2;
    a.y = s->a4;
    b.x = s->a6;
    b.y = s->a8;
    DrawLineWithMode(&a, &b, GFX_FG_COLOR);
}
void SeGfx_StaticOp02_Line(struct dsrc *s)
{
    struct pt a, b;
    a.x = s->a2;
    a.y = s->a4;
    b.x = s->a6;
    b.y = s->a8;
    DrawLineWithMode(&a, &b, GFX_FG_COLOR);
}
void SeGfx_StaticOp15_DottedLine(struct dsrc *s)
{
    struct pt a, b;
    a.x = s->a2;
    a.y = s->a4;
    b.x = s->a6;
    b.y = s->a8;
    DrawDottedLineWithMode(&a, &b, GFX_FG_COLOR);
}

struct bsrc { unsigned char op[2]; long bits; unsigned int pos; unsigned int w; int h; };
extern void ColorBlit2_LargeCodeBlock(struct rect *, long, int);
extern void SeGfx_StaticOp03_Bitmap(struct bsrc *s);

void SeGfx_StaticOp03_Bitmap(struct bsrc *s)
{
    struct rect r;
    struct rect *q;
    int *py;
    unsigned int *pp;
    q = &r;
    py = &q->y0;
    pp = &s->pos;
    *py = *pp / 40;
    q->x0 = (*pp % 40) << 3;
    q->y1 = s->h + q->y0;
    q->x1 = q->x0 + (s->w << 3);
    ColorBlit2_LargeCodeBlock(q, s->bits, GFX_FG_COLOR);
}

/* cc900-module: Display_FillPaletteBandFromEntry_Impl DrawQueue_Alloc DrawRing_Post IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct icmd { void (*fn)(struct icmd *); unsigned int w; };
extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern void Display_FillPalBandFromEnt_Impl(unsigned int);
void GraphicsRender_ByteData_Code(struct icmd *q);
extern void Display_FillPalBandFromEntry(unsigned int w);
extern void GraphicsRender_ByteData_Code(struct icmd *q);

/* cc900-name: Display_FillPalBandFromEntry=Display_FillPaletteBandFromEntry */
/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
/* cc900-name: Display_FillPalBandFromEnt_Impl=Display_FillPaletteBandFromEntry_Impl */
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
