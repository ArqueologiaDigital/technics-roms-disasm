/* Phase 6, lane_p6 helper J, round 3, module 273, form b: SetApTimer refinement.  As form a but the base taken
   by a separate statement (tbl = ram_2f844; t = &tbl[i]) and the scan pointer as &tbl[cur]; the prev / next
   stores keep r35's macro spelling, which already matched the ROM's (muls, lda xwa,(xwa+iy)). */
/* cc900-module: DrawString IsPointOnScreen SetChangeRect */   /* scripts/analysis/cc900/module_calls.py v10 */

struct apt { int prev; int next; unsigned long time; long obj; long target; long event; long param; };
extern struct apt ram_2f844[];
extern unsigned long ram_30444;
extern int ram_30448;
#define APTB(b, n) ((struct apt *)((char *)(b) + (n) * 24))

void SetApTimer(unsigned long time, long obj, long target, long event, long param)
{
	struct apt *u;
	int cur;
	int prev;
	unsigned int i;
	struct apt *t;
	struct apt *tbl;

	for (i = 0; i < 128; i++) {
		tbl = ram_2f844;
		t = &tbl[i];
		if (t->obj == -1) {
			t->time = ram_30444 + time;
			t->obj = obj;
			t->target = target;
			t->event = event;
			t->param = param;
			cur = ram_30448;
			if (cur == -1) {
				ram_30448 = i;
				break;
			}
			prev = -1;
			while ((u = &tbl[cur])->time <= t->time) {
				prev = cur;
				cur = u->next;
				if (cur == -1)
					break;
			}
			t->prev = prev;
			t->next = cur;
			if (prev != -1)
				APTB(tbl, prev)->next = i;
			if (cur != -1)
				APTB(tbl, cur)->prev = i;
			if (cur == ram_30448)
				ram_30448 = i;
			break;
		}
	}
	if (i == 128)
		for (;;)
			;
}

/* New, round 3, form b: DrawStringRightJustify with the declarations in helper I's DrawStringCentered order;
   DrawBitmapSPFast_Impl with the destination as an integer sum (base loaded as an immediate after the index, the
   ROM's ld xde,OFFSCREEN_BUFFER_1 / add xde,xwa) and the row counter in its own statement. */
struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern void ConvertStrings(char *src, char *dst);
extern int CalcTotalWidth(char *, long);
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern int GetCenteredDelta(long);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
extern int IsPointOnScreen(struct pt *);
extern void SetChangeRect(struct rect *r);
extern void *__cdecl Mem_Copy(void *, void *, int);
extern unsigned char OFFSCREEN_BUFFER_1[][320];

void DrawStringRightJustify(struct rect *r, struct pt *p, char *s, long font, int a, int b)
{
	struct pt at;
	char buf[256];
	int h;
	int w;
	int d;

	ConvertStrings(s, buf);
	w = CalcTotalWidth(buf, font);
	h = GetCharHeight(font);
	d = GetCharDescent(font);
	at = *p;
	at.x = r->x1 - 4 - w;
	at.y -= (h - d) / 2;
	at.y += GetCenteredDelta(font);
	DrawString(r, &at, buf, font, a, b);
}

void DrawBitmapSPFast_Impl(struct pt *p, unsigned char *bmp, int w, unsigned int hgt)
{
	unsigned int i;
	unsigned int y;
	struct rect r;
	unsigned char *d;

	if (IsPointOnScreen(p) == 0)
		return;
	y = p->y;
	d = (unsigned char *)((long)OFFSCREEN_BUFFER_1 + ((long)p->x + (long)(int)y * 320));
	for (i = 0; i < hgt; i++) {
		if (y >= 240)
			break;
		Mem_Copy(d, bmp, w);
		bmp += (long)((w + 1) / 2) * 2;
		d += 320;
		y++;
	}
	r.y0 = p->y;
	r.x0 = p->x;
	r.x1 = p->x + w;
	r.y1 = p->y + hgt;
	SetChangeRect(&r);
}
