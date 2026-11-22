/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_30r1m273a.c (2026-11-22-13-p6-r80)
   sha256 94f4dc5a21f45ac79293876a25c04d4fbf389a285201906bafb3b2097b6b12b3 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
struct icon { int w; int h; unsigned char *data; };
extern unsigned char OFFSCREEN_BUFFER_1[][320];
extern unsigned int DrawIcons_PixelPairTable[];
extern int IsPointOnScreen(struct pt *);
extern void SetChangeRect(struct rect *r);
void DrawIcons_Impl(struct pt *p, long n)
{
	struct icon *e;
	unsigned char *src;
	struct rect r;
	struct pt c;
	unsigned int *d;
	unsigned char *dst;
	int row;
	int col;

	if (n == 0)
		return;
	if (IsPointOnScreen(p) == 0)
		return;
	e = (struct icon *)0x938000L + n;
	src = e->data;
	c.y = p->y;
	dst = &OFFSCREEN_BUFFER_1[p->y][p->x];
	for (row = 0; row < 24; row++) {
		if (c.y >= 240)
			break;
		d = (unsigned int *)dst;
		for (col = 0; col < 12; col++)
			*d++ = DrawIcons_PixelPairTable[*src++];
		c.y++;
		dst += 320;
	}
	r.y0 = p->y;
	r.x0 = p->x;
	r.x1 = e->w + p->x;
	r.y1 = e->h + p->y;
	SetChangeRect(&r);
}
