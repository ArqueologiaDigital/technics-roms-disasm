/* lane_p6 helper Q, round 30r1, form a: module 273 (ui/drawing_primitives.s), DrawIcons_Impl (225 B, roots30_Q):
   draws icon n of the icon descriptor table at 0x938000 (8 B: width, height, 4-bpp data) at *p into
   OFFSCREEN_BUFFER_1, 24 rows of 12 bytes, each byte expanded to two pixels through DrawIcons_PixelPairTable,
   stopping at row 240; then marks the changed rectangle.  Form a: the clip row in a struct pt local (the ROM keeps
   its address, xsp+30, in the frame), the rectangle filled y0, x0, x1, y1 as the ROM stores it.
   cc900-options: -O3 -Xr
*/
/* cc900-module: IsPointOnScreen SetChangeRect */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
struct icon { int w; int h; unsigned char *data; };
extern unsigned char OFFSCREEN_BUFFER_1[][320];
extern unsigned int DrawIcons_PixelPairTable[];
extern int IsPointOnScreen(struct pt *);
extern void SetChangeRect(struct rect *r);
extern void DrawIcons_Impl(struct pt *p, long n);

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
