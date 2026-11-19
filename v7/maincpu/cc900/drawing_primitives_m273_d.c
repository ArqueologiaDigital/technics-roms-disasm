/* Functions of ui/drawing_primitives.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ColorBlit2 DrawBitmap_Impl DrawBox DrawQueue_Alloc DrawRing_Post DrawString IS_XSP_INSIDE_4K_REGION_AT_1C032 */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern void ConvertStrings(char *src, char *dst);
extern int CalcTotalWidth(char *s, long font);
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern int GetCenteredDelta(long);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
extern void DrawStringCentered(struct rect *clip, struct pt *pos, char *s, long font, int fg, int bg);
extern void DrawStringRightJustify(struct rect *r, struct pt *p, char *s, long font, int a, int b);
extern int IsDrawTask(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
struct bmcmd { void (*fn)(struct bmcmd *); struct pt p; unsigned char *bmp; };
extern void DrawBitmap_Impl(struct pt *, unsigned char *);
extern void DrawBitmap_QueuedExec(struct bmcmd *q);
extern void DrawBitmap(struct pt *p, unsigned char *bmp);

void DrawStringCentered(struct rect *clip, struct pt *pos, char *s, long font, int fg, int bg)
{
    struct pt pt;
    char buf[256];
    int h;
    int w;
    int d;

    ConvertStrings(s, buf);
    w = CalcTotalWidth(buf, font);
    h = GetCharHeight(font);
    d = GetCharDescent(font);
    pt = *pos;
    pt.x -= w / 2;
    pt.y -= (h - d) / 2;
    pt.y += GetCenteredDelta(font);
    s = buf;
    DrawString(clip, &pt, s, font, fg, bg);
}

void DrawStringRightJustify(struct rect *r, struct pt *p, char *s, long font, int a, int b)
{
    int w;
    int h;
    int d;
    struct pt at;
    char buf[256];

    ConvertStrings(s, buf);
    w = CalcTotalWidth(buf, font);
    h = GetCharHeight(font);
    d = GetCharDescent(font);
    at = *p;
    at.x = r->x1 - 4 - w;
    at.y -= (h - d) / 2;
    at.y += GetCenteredDelta(font);
    s = buf;
    DrawString(r, &at, s, font, a, b);
}

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void DrawBitmap(struct pt *p, unsigned char *bmp)
{
	struct bmcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawBitmap_Impl(p, bmp);
	} else {
		q = (struct bmcmd *)DrawQueue_Alloc(sizeof(struct bmcmd));
		q->fn = DrawBitmap_QueuedExec;
		q->p = *p;
		q->bmp = bmp;
		DrawRing_Post(q);
	}
}
