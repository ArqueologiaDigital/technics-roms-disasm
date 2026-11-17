/* FORM B (the four scalars declared b, k, col, row).  Form a's notes follow.
   Phase 6, lane_p6 helper G, round 12, module 273, form a: DrawMonoBitmap_Impl alone (its notes: round 9's
   p6_G_9m273a.c).  Run 2026-11-16-128-p6-r27: `&b; &k; &r;` put the parameters and b / k in the frame (the ROM's
   parameter stores now come out), but the address-taken b / k went above the plain counter col (k 10, b 12; col 4,
   a temporary 6) and row went to BC; the ROM has b 2, k 4, col 6, row 8, then the temporaries 10 / 14 and pt 18.
   So here all four scalars are address-taken alike: in r27 the address-taken pair took slots last-declared lowest,
   so form a declares them row, col, k, b; form b declares them b, k, col, row. */
/* cc900-module: SetChangeRect */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };

extern void SetChangeRect(struct rect *r);
extern unsigned char OFFSCREEN_BUFFER_1[][320];
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern unsigned int GFX_BG_COLOR;
extern unsigned char *WALLPAPER_BITMAP;

#define SCREEN OFFSCREEN_BUFFER_1

void DrawMonoBitmap_Impl(struct rect *r, unsigned char *bits, int color)
{
	struct pt pt;
	unsigned char b, k;
	unsigned int col, row;
	int c;
	unsigned char *d, *s;

	&b;
	&k;
	&col;
	&row;
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
