/* Functions of display/graphics_text_vga.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ColorBlit2_LargeCodeBlock DrawDottedLineWithMode DrawLineWithMode */   /* scripts/analysis/cc900/module_calls.py v10 */

struct dsrc { unsigned char op[2]; int a2; int a4; int a6; int a8; };
struct pt { int x; int y; };
extern int GFX_FG_COLOR;
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
