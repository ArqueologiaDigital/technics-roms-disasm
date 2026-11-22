/* lane_p6 helper J, round 27r1, form a: module 270 (ui/ui_control_panel.s), Arrow_DrawHorizontal, the twin of
   module 159's PaintArrow_DrawFilled (p6_J_27r1m159a.c, same body, DrawLineHelper -> StylCnvStorOkFunc_DataBlock).
   Box XWA, colour BC, tail_x DE; tail_y and dir on the stack (ArrowProc pushes tail_y first, dir last: dir is the
   last parameter); retd 4.  Frame: len +4, step +6, rev +8, swap +10, i +14, p2 +16, p1 +20, r +24.
   Form a: the mode test as a switch (case 2 then case 3 in source: V4.23 compares in reverse order), default first;
   `half /= 2` as its own statement before the centre line.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawLineHelper */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };

extern void DrawLineHelper(struct pt *a, struct pt *b, int c, int swap);

void Arrow_DrawHorizontal(struct rect *box, int colour, unsigned int tail_x, unsigned int tail_y, int dir)
{
	struct rect r;
	struct pt p1;
	struct pt p2;
	unsigned int len;
	int step;
	int rev;
	int swap;
	unsigned int i;
	unsigned int head;
	unsigned int half;

	switch (dir) {
	default:
		rev = (dir != 1);
		swap = 0;
		r = *box;
		break;
	case 2:
		rev = 1;
		swap = 1;
		r.x0 = box->y0;
		r.y0 = box->x0;
		r.x1 = box->y1;
		r.y1 = box->x1;
		break;
	case 3:
		rev = 0;
		swap = 1;
		r.x0 = box->y0;
		r.y0 = box->x0;
		r.x1 = box->y1;
		r.y1 = box->x1;
		break;
	}
	head = (r.x1 - r.x0) * tail_x / 100;
	half = (r.y1 - r.y0) * tail_y / 100;
	len = r.x1 - r.x0 - head;
	if (rev != 0) {
		p1.x = r.x1;
		step = -1;
	} else {
		p1.x = r.x0;
		step = 1;
	}
	p2.x = p1.x;
	half /= 2;
	p1.y = r.y0 + (r.y1 - r.y0) / 2 + half;
	p2.y = r.y0 + (r.y1 - r.y0) / 2 - half;
	for (i = 0; i < head; i++) {
		DrawLineHelper(&p1, &p2, colour, swap);
		p1.x += step;
		p2.x += step;
	}
	if (rev != 0) {
		p1.x = r.x1 - head;
		step = -1;
	} else {
		p1.x = r.x0 + head;
		step = 1;
	}
	p2.x = p1.x;
	p1.y = r.y0;
	p2.y = r.y0 + (r.y1 - r.y0) / 2;
	for (i = 0; i < len; i++) {
		DrawLineHelper(&p1, &p2, colour, swap);
		p2.x += step;
	}
	p2.x = p1.x;
	p1.y = r.y1;
	p2.y = r.y1 - (r.y1 - r.y0) / 2;
	for (i = 0; i < len; i++) {
		DrawLineHelper(&p1, &p2, colour, swap);
		p2.x += step;
	}
}
