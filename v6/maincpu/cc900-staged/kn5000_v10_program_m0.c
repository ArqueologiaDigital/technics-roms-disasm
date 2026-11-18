/* Functions of kn5000_v6_program.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawBox DrawFunc_Return DrawQueue_Alloc DrawRing_Post DrawString IS_XSP_INSIDE_4K_REGION_AT_1C032 TextRender_BeginDraw */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
struct dq { void *fn; struct rect r; struct pt p; char *s; long font; int a; int b; unsigned char mode; };
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern int DRAW_ENABLED;
extern void DrawFunc_Return(void *p);
extern void TextRender_BeginDraw(struct rect *, struct pt *, char *, long, int, int);
extern void DrawText_PopAndReturn_Code(struct dq *q);

void DrawText_PopAndReturn_Code(struct dq *q)
{
    struct rect *r;
    struct pt *p;
    long font;
    int a;
    int b;

    r = &q->r;
    p = &q->p;
    font = q->font;
    a = q->a;
    b = q->b;
    COLORBLIT_MODE_ACTIVE = q->mode;
    if (DRAW_ENABLED != 0)
        TextRender_BeginDraw(r, p, q->s, font, a, b);
    DrawFunc_Return(q->s);
}
