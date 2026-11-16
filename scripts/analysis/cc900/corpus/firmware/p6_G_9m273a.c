/* Phase 6, lane_p6 helper G, round 9, module 273 (notes/cc900-phase6-2026-11-16/modules_v10.tsv), form a:
   DrawDottedLine_Impl (ui/ui_window_procs.s), new.  The draw task's dotted line from *p1 to *p2 in colour `color`,
   written straight into the 320 x 240 offscreen buffer at 0x43c00 with a 2-on / 3-off pattern (the counter draws at
   0 and 1, counts to 4, and resets after 3); horizontal and vertical lines step one axis, other lines step the longer
   axis by one and the other in 16.16 fixed point (the reused dx / dy locals, rounded with 0x8000), then
   SetChangeRect gets the end points' box (stored y0, x0, x1, y1 in the ROM's order).
   The ROM loads the buffer's base as an immediate after computing the index (a constant pointer, VRAM here); form a
   writes the index y * 320 + x, form b x + y * 320 and the sign tests as if-statements.
   Read from the hand assembly: locals cur (highest slot), the rectangle, then dx, dy, sx, sy, the counter from the
   bottom; the two `&p->y` addresses and `&cur` are V4.23's own temporaries; i in XBC, the quotient in XIZ. */
/* cc900-module: SetChangeRect */

#define VRAM ((unsigned char *)0x43c00L)

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };

extern void SetChangeRect(struct rect *r);

void DrawDottedLine_Impl(struct pt *p1, struct pt *p2, int color)
{
	struct pt cur;
	struct rect r;
	long dx, dy, sx, sy;
	unsigned char cnt;
	long i, q;

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
				if (cnt <= 1) VRAM[(long)cur.y * 320 + cur.x] = color;
				cnt++;
			}
			cur.y += sy;
		}
	} else if (dy == 0) {
		for (i = 0; i <= dx; i++) {
			if (cnt > 3)
				cnt = 0;
			else {
				if (cnt <= 1) VRAM[(long)cur.y * 320 + cur.x] = color;
				cnt++;
			}
			cur.x += sx;
		}
	} else if (dy > dx) {
		q = (dx << 16) / dy;
		sx = sx * q;
		dx = cur.x;
		dx <<= 16;
		dx += 0x8000;
		for (i = 0; i <= dy; i++) {
			if (cnt > 3)
				cnt = 0;
			else {
				if (cnt <= 1) VRAM[(long)cur.y * 320 + cur.x] = color;
				cnt++;
			}
			dx += sx;
			cur.x = dx >> 16;
			cur.y += sy;
		}
	} else {
		q = (dy << 16) / dx;
		sy = sy * q;
		dy = cur.y;
		dy <<= 16;
		dy += 0x8000;
		for (i = 0; i <= dx; i++) {
			if (cnt > 3)
				cnt = 0;
			else {
				if (cnt <= 1) VRAM[(long)cur.y * 320 + cur.x] = color;
				cnt++;
			}
			dy += sy;
			cur.y = dy >> 16;
			cur.x += sx;
		}
	}
	r.y0 = p1->y;
	r.x0 = p1->x;
	r.x1 = p2->x;
	r.y1 = p2->y;
	SetChangeRect(&r);
}

/* DrawMonoBitmap_Impl (ui/ui_window_procs.s), new: a 1-bit bitmap (8 pixels per byte, MSB first, one byte per row of
   each 8-pixel column) drawn into the box *r by COLORBLIT_MODE_ACTIVE: mode 0 paints set bits in `color` and clear
   bits in GFX_BG_COLOR, keeping each pixel's bits 5-6 (0x60) and flipping them when the new colour's bit 7 differs
   from the pixel's; colour 245 takes the wallpaper's pixel instead.  Modes 1 / 2 set bit 5 / 6 of the pixel to its
   bit 7 where the bitmap bit is clear and to its inverse where it is set.  Then SetChangeRect(r).
   Read from the hand assembly: b, k, col, row from the bottom of the frame, two V4.23 temporaries (&pt, &pt.y), pt;
   the colour in IZ (pushw iz), the pixel pointer in XIX; the buffer's base by lda (an extern array here, where
   DrawDottedLine_Impl loads it as an immediate). */
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern unsigned int GFX_BG_COLOR;
extern unsigned char *WALLPAPER_BITMAP;
extern unsigned char OFFSCREEN_BUFFER_1[][320];

void DrawMonoBitmap_Impl(struct rect *r, unsigned char *bits, int color)
{
	struct pt pt;
	unsigned char b, k;
	unsigned int col, row;
	int c;
	unsigned char *d, *s;

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
						d = &OFFSCREEN_BUFFER_1[pt.y][pt.x];
						if (c != 245) {
							*d &= 0x60;
							*d += c & 0x9f;
							if ((c & 0x80) != (*d & 0x80)) *d ^= 0x60;
						} else {
							s = &WALLPAPER_BITMAP[pt.x + (long)pt.y * 320];
							*d &= 0x60;
							*d += *s & 0x9f;
							if ((*s & 0x80) != (*d & 0x80)) *d ^= 0x60;
						}
					} else {
						c = GFX_BG_COLOR;
						d = &OFFSCREEN_BUFFER_1[pt.y][pt.x];
						if (c != 245) {
							*d &= 0x60;
							*d += c & 0x9f;
							if ((c & 0x80) != (*d & 0x80)) *d ^= 0x60;
						} else {
							s = &WALLPAPER_BITMAP[pt.x + (long)pt.y * 320];
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
						d = &OFFSCREEN_BUFFER_1[pt.y][pt.x];
						if (*d & 0x80) *d &= ~0x20;
						else *d |= 0x20;
					} else {
						d = &OFFSCREEN_BUFFER_1[pt.y][pt.x];
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
						d = &OFFSCREEN_BUFFER_1[pt.y][pt.x];
						if (*d & 0x80) *d &= ~0x40;
						else *d |= 0x40;
					} else {
						d = &OFFSCREEN_BUFFER_1[pt.y][pt.x];
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
