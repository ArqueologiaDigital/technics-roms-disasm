/* lane_p6 helper J, round 27r1, form c: module 159 (audio/sound_editor_ui.s), PaintArrow_DrawFilled, the twin of
   module 270's Arrow_DrawHorizontal (p6_J_27r1m270c.c, same body, StylCnvStorOkFunc_DataBlock -> DrawLineHelper).
   Box XWA, colour BC, tail_x DE; tail_y and dir on the stack (StylCnvStorBnk_ProcDataBlock pushes tail_y first, dir last: dir is the
   last parameter); retd 4.  Frame: len +4, step +6, rev +8, swap +10, i +14, p2 +16, p1 +20, r +24.
   Form c: form a's `half /= 2` statement with form b's shared swapped copy (case 2 `goto sw` into case 3's tail).
   cc900-options: -O3 -Xr
*/
/* cc900-module: StylCnvStorOkFunc_DataBlock */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };

extern void StylCnvStorOkFunc_DataBlock(struct pt *a, struct pt *b, int c, int swap);

void PaintArrow_DrawFilled(struct rect *box, int colour, unsigned int tail_x, unsigned int tail_y, int dir)
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
		goto sw;
	case 3:
		rev = 0;
	sw:
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
		StylCnvStorOkFunc_DataBlock(&p1, &p2, colour, swap);
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
		StylCnvStorOkFunc_DataBlock(&p1, &p2, colour, swap);
		p2.x += step;
	}
	p2.x = p1.x;
	p1.y = r.y1;
	p2.y = r.y1 - (r.y1 - r.y0) / 2;
	for (i = 0; i < len; i++) {
		StylCnvStorOkFunc_DataBlock(&p1, &p2, colour, swap);
		p2.x += step;
	}
}
