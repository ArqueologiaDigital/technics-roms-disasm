/* FORM B of p6_G_10m273a.c: DrawDottedLine_Impl's fixed-point start written `dx = (long)cur.x; dx <<= 16;`, and
   DrawMonoBitmap_Impl's colour a `register int`.  Form a's notes follow.
   Phase 6, lane_p6 helper G, round 10, module 273 (notes/cc900-phase6-2026-11-16/modules_v10.tsv), form a.
   Run 2026-11-16-118-p6-r23 gave both functions +1 (the frame).  Read against the ROM:
   - DrawDottedLine_Impl: everything but three spots matched.  (1) The ROM keeps the quotient q in XIZ and spills
     V4.23's `&cur` temporary to the frame (xsp+30, frame 52); V4.23 gave XIZ to `&cur` and passed q straight on
     (frame 48): q is `register` here.  (2) The pixel address: the ROM scales y by 320 with sll (array index scaling,
     where `(long)y * 320` gives sla) and loads y before x: a constant pointer to 320-byte rows, VRAM[y][x].
     (3) `dx = cur.x; dx <<= 16;` re-read dx between the store and the shift where the ROM shifts the stored register:
     written `dx = dx << 16` here (form b: `<<=` with an explicit cast on the first store).
   - DrawMonoBitmap_Impl: V4.23 kept the bit byte b and the bit counter k in the bank's byte registers, and the box
     pointer in XWA; the ROM keeps b and k in the frame (xsp+2, xsp+4), the parameters too, and the colour in IZ
     (pushw iz).  Here b and k are `volatile` (form b: also the colour a `register int`).
   The functions' own notes are in round 9's p6_G_9m273a.c. */
/* cc900-module: SetChangeRect */

#define VRAM ((unsigned char (*)[320])0x43c00L)

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };

extern void SetChangeRect(struct rect *r);

void DrawDottedLine_Impl(struct pt *p1, struct pt *p2, int color)
{
	struct pt cur;
	struct rect r;
	long dx, dy, sx, sy;
	unsigned char cnt;
	long i;
	register long q;

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
				if (cnt <= 1) VRAM[cur.y][cur.x] = color;
				cnt++;
			}
			cur.y += sy;
		}
	} else if (dy == 0) {
		for (i = 0; i <= dx; i++) {
			if (cnt > 3)
				cnt = 0;
			else {
				if (cnt <= 1) VRAM[cur.y][cur.x] = color;
				cnt++;
			}
			cur.x += sx;
		}
	} else if (dy > dx) {
		q = (dx << 16) / dy;
		sx = sx * q;
		dx = (long)cur.x;
		dx <<= 16;
		dx += 0x8000;
		for (i = 0; i <= dy; i++) {
			if (cnt > 3)
				cnt = 0;
			else {
				if (cnt <= 1) VRAM[cur.y][cur.x] = color;
				cnt++;
			}
			dx += sx;
			cur.x = dx >> 16;
			cur.y += sy;
		}
	} else {
		q = (dy << 16) / dx;
		sy = sy * q;
		dy = (long)cur.y;
		dy <<= 16;
		dy += 0x8000;
		for (i = 0; i <= dx; i++) {
			if (cnt > 3)
				cnt = 0;
			else {
				if (cnt <= 1) VRAM[cur.y][cur.x] = color;
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

extern unsigned char COLORBLIT_MODE_ACTIVE;
extern unsigned int GFX_BG_COLOR;
extern unsigned char *WALLPAPER_BITMAP;
extern unsigned char OFFSCREEN_BUFFER_1[][320];

void DrawMonoBitmap_Impl(struct rect *r, unsigned char *bits, int color)
{
	struct pt pt;
	volatile unsigned char b, k;
	unsigned int col, row;
	register int c;
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
