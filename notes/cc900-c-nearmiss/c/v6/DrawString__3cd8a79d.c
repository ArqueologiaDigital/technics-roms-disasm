/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/drawing_primitives_m273.c (2026-11-18-28-p6-r36)
   sha256 3cd8a79d1347281f0d4750a4952b700028d8d9e18a624b59329febbf03fe1725 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct pt { int x, y; };
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
struct rect { int x0, y0, x1, y1; };
extern int IsDrawTask(void);
extern int __cdecl Strlen(char *);
extern char *__cdecl Strcpy(char *, char *);
struct dscmd { void (*fn)(struct dscmd *); struct rect r; struct pt p; char *s; long font; int a; int b; };
extern void DrawString_Impl(struct rect *, struct pt *, char *, long, int, int);
extern void DrawString_DeferredPath_Code(struct dscmd *);
extern void DrawString_DeferredPath_Code(struct dscmd *q);
void DrawString(struct rect *r, struct pt *p, char *s, long font, int a, int b)
{
	struct dscmd *q;
	char *buf;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawString_Impl(r, p, q->s, font, a, b);
	} else {
		buf = (char *)DrawQueue_Alloc(Strlen(s) + 1);
		q = (struct dscmd *)DrawQueue_Alloc(sizeof(struct dscmd));
		q->fn = DrawString_DeferredPath_Code;
		q->r = *r;
		q->p = *p;
		q->s = buf;
		Strcpy(buf, s);
		q->font = font;
		q->a = a;
		q->b = b;
		DrawRing_Post(q);
	}
}
