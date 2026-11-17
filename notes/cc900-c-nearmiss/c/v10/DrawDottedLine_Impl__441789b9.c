/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_10m273a.c (2026-11-16-123-p6-r25)
   sha256 441789b936eb37eb6d0d1e66344bac32e2cafac56d8cd19a41d36e291bdadfdf (tar-sha256); compiled at -O3 -Xr */
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
		dx = cur.x;
		dx = dx << 16;
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
		dy = cur.y;
		dy = dy << 16;
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
