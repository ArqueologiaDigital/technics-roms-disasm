/* FORM B of p6_G_11m273a.c: DrawDottedLine_Impl indexes the buffer as a byte array with the unsigned long index;
   DrawMonoBitmap_Impl declares its four scalars in reverse order.  Form a's notes follow.
   Phase 6, lane_p6 helper G, round 11, module 273 (notes/cc900-phase6-2026-11-16/modules_v10.tsv), form a.
   Run 2026-11-16-123-p6-r25: both functions still +1 (the frame); `volatile` and `register` were ignored.
   - DrawDottedLine_Impl.  (1) The frame: the ROM's slot xsp+30 holds `&cur` for the two fixed-point loops (loaded to
     XDE before each), and XIZ holds the quotient.  Read with the frame-slot pattern of this function (structs and
     address-taken locals from the top in declaration order: cur 42, r 34, then 30; plain scalars from the bottom:
     dx 4 .. cnt 20, V4.23's own temporaries 22 / 26), that is a named pointer `pp = &cur` declared after r and kept
     in the frame by a no-code `&pp;` (helper F's lever).  (2) The pixel: round 10's `VRAM[y][x]` gave the ROM's sll
     row scaling and y-before-x order, but a 16-bit `(xhl+wa)` index; the ROM widens x, adds, then loads the buffer's
     base as an immediate: an unsigned long index (`y * 320UL + x`), added here to the buffer's address as an integer
     (form a) or used to index the extern array (form b).  (3) `dx = cur.x; dx <<= 16` re-reads dx where the ROM
     shifts the value it stored: one nested assignment, `dx = (dx = pp->x) << 16`.
   - DrawMonoBitmap_Impl.  V4.23 kept the bit byte b and counter k in byte registers and the box pointer in XWA where
     the ROM keeps all three in the frame: `&b; &k; &r;` (form b also reverses the four scalars' declaration order,
     in case address-taken locals take their slots the other way).  The wallpaper index is `x + y * 320UL`: the ROM
     scales it with sll too, after widening x.
   The functions' own notes are in round 9's p6_G_9m273a.c. */
/* cc900-module: SetChangeRect */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };

extern void SetChangeRect(struct rect *r);
extern unsigned char OFFSCREEN_BUFFER_1[][320];

#define PIXEL(p) (((unsigned char *)OFFSCREEN_BUFFER_1)[(p).y * 320UL + (p).x])

void DrawDottedLine_Impl(struct pt *p1, struct pt *p2, int color)
{
	struct pt cur;
	struct rect r;
	struct pt *pp;
	long dx, dy, sx, sy;
	unsigned char cnt;
	long i, q;

	&pp;
	cnt = 0;
	sx = p2->x > p1->x ? 1 : -1;
	sy = p2->y > p1->y ? 1 : -1;
	dx = sx == 1 ? p2->x - p1->x : p1->x - p2->x;
	dy = sy == 1 ? p2->y - p1->y : p1->y - p2->y;
	if (dx == 0 && dy == 0) return;
	cur = *p1;
	if (dx == 0) {
		for (i = 0; i <= dy; i++) {
			if (cnt > 3)
				cnt = 0;
			else {
				if (cnt <= 1) PIXEL(cur) = color;
				cnt++;
			}
			cur.y += sy;
		}
	} else if (dy == 0) {
		for (i = 0; i <= dx; i++) {
			if (cnt > 3)
				cnt = 0;
			else {
				if (cnt <= 1) PIXEL(cur) = color;
				cnt++;
			}
			cur.x += sx;
		}
	} else {
		pp = &cur;
		if (dy > dx) {
			q = (dx << 16) / dy;
			sx = sx * q;
			dx = (dx = pp->x) << 16;
			dx += 0x8000;
			for (i = 0; i <= dy; i++) {
				if (cnt > 3)
					cnt = 0;
				else {
					if (cnt <= 1) PIXEL(*pp) = color;
					cnt++;
				}
				dx += sx;
				pp->x = dx >> 16;
				pp->y += sy;
			}
		} else {
			q = (dy << 16) / dx;
			sy = sy * q;
			dy = (dy = pp->y) << 16;
			dy += 0x8000;
			for (i = 0; i <= dx; i++) {
				if (cnt > 3)
					cnt = 0;
				else {
					if (cnt <= 1) PIXEL(*pp) = color;
					cnt++;
				}
				dy += sy;
				pp->y = dy >> 16;
				pp->x += sx;
			}
		}
	}
	r.y0 = p1->y;
	r.x0 = p1->x;
	r.x1 = p2->x;
	r.y1 = p2->y;
	SetChangeRect(&r);
}

extern unsigned char COLORBLIT_MODE_ACTIVE;
extern unsigned int GFX_BG_COLOR;
extern unsigned char *WALLPAPER_BITMAP;

#define SCREEN OFFSCREEN_BUFFER_1

void DrawMonoBitmap_Impl(struct rect *r, unsigned char *bits, int color)
{
	struct pt pt;
	unsigned int row, col;
	unsigned char k, b;
	int c;
	unsigned char *d, *s;

	&b;
	&k;
	&r;
	switch (COLORBLIT_MODE_ACTIVE) {
	case 0:
		for (col = 0; col < r->x1 - r->x0; col += 8)
			for (row = 0; row < r->y1 - r->y0; row++) {
				pt.x = r->x0 + col;
				pt.y = r->y0 + row;
				b = *bits;
				for (k = 0; k < 8; k++) {
					if (b & 0x80) {
						c = color;
						d = &SCREEN[pt.y][pt.x];
						if (c != 245) {
							*d &= 0x60;
							*d += c & 0x9f;
							if ((c & 0x80) != (*d & 0x80)) *d ^= 0x60;
						} else {
							s = &WALLPAPER_BITMAP[pt.x + pt.y * 320UL];
							*d &= 0x60;
							*d += *s & 0x9f;
							if ((*s & 0x80) != (*d & 0x80)) *d ^= 0x60;
						}
					} else {
						c = GFX_BG_COLOR;
						d = &SCREEN[pt.y][pt.x];
						if (c != 245) {
							*d &= 0x60;
							*d += c & 0x9f;
							if ((c & 0x80) != (*d & 0x80)) *d ^= 0x60;
						} else {
							s = &WALLPAPER_BITMAP[pt.x + pt.y * 320UL];
							*d &= 0x60;
							*d += *s & 0x9f;
							if ((*s & 0x80) != (*d & 0x80)) *d ^= 0x60;
						}
					}
					b <<= 1;
					pt.x++;
				}
				bits++;
			}
		break;
	case 1:
		for (col = 0; col < r->x1 - r->x0; col += 8)
			for (row = 0; row < r->y1 - r->y0; row++) {
				pt.x = r->x0 + col;
				pt.y = r->y0 + row;
				b = *bits;
				for (k = 0; k < 8; k++) {
					if (b & 0x80) {
						d = &SCREEN[pt.y][pt.x];
						if (*d & 0x80) *d &= ~0x20;
						else *d |= 0x20;
					} else {
						d = &SCREEN[pt.y][pt.x];
						if (*d & 0x80) *d |= 0x20;
						else *d &= ~0x20;
					}
					b <<= 1;
					pt.x++;
				}
				bits++;
			}
		break;
	case 2:
		for (col = 0; col < r->x1 - r->x0; col += 8)
			for (row = 0; row < r->y1 - r->y0; row++) {
				pt.x = r->x0 + col;
				pt.y = r->y0 + row;
				b = *bits;
				for (k = 0; k < 8; k++) {
					if (b & 0x80) {
						d = &SCREEN[pt.y][pt.x];
						if (*d & 0x80) *d &= ~0x40;
						else *d |= 0x40;
					} else {
						d = &SCREEN[pt.y][pt.x];
						if (*d & 0x80) *d |= 0x40;
						else *d &= ~0x40;
					}
					b <<= 1;
					pt.x++;
				}
				bits++;
			}
		break;
	}
	SetChangeRect(r);
}
