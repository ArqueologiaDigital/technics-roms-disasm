/* lane_p6 helper Q, round 30r1, form b: module 273 (ui/drawing_primitives.s), DrawIcons_Impl (225 B, roots30_Q):
   draws icon n of the icon descriptor table at 0x938000 (8 B: width, height, 4-bpp data) at *p into
   OFFSCREEN_BUFFER_1, 24 rows of 12 bytes, each byte expanded to two pixels through DrawIcons_PixelPairTable,
   stopping at row 240; then marks the changed rectangle.  Form b (form a: pointer + n, rect y0 first): the entry
   address as an integer sum n * 8 + 0x938000, the rectangle filled x0, y0, x1, y1, the clip row a pointer to a
   local copy of the row.
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
	int *py;
	int *pc;
	struct rect r;
	int cy;
	unsigned int *d;
	unsigned char *dst;
	int row;
	int col;

	if (n == 0)
		return;
	if (IsPointOnScreen(p) == 0)
		return;
	e = (struct icon *)(n * 8 + 0x938000L);
	src = e->data;
	pc = &cy;
	py = &p->y;
	*pc = *py;
	dst = &OFFSCREEN_BUFFER_1[*py][p->x];
	for (row = 0; row < 24; row++) {
		if (*pc >= 240)
			break;
		d = (unsigned int *)dst;
		for (col = 0; col < 12; col++)
			*d++ = DrawIcons_PixelPairTable[*src++];
		(*pc)++;
		dst += 320;
	}
	r.x0 = p->x;
	r.y0 = *py;
	r.x1 = e->w + p->x;
	r.y1 = e->h + *py;
	SetChangeRect(&r);
}
