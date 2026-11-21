/* lane_p6 helper A, round 22r2, form b: module 128 (display/scoop_display.s), alternatives to form a.
   BoundOp08: struct assignment of the table entry; BoundOp04 / Handler0 / Handler3: x before row
   (`r.x0` first); Handler1 / Handler2: locals declared in the opposite order (lowest frame slot first);
   Handler3: icon read first.
   cc900-options: -Xr
*/

struct rect { int x0; int y0; int x1; int y1; };
struct pt { int x, y; };
struct cellbox { unsigned int pos; unsigned int w; unsigned int h; };
struct bfld { unsigned char pad[2]; unsigned int addr; unsigned char mask; unsigned char shift; unsigned char b6;
	void *tbl; };
struct dsrc { unsigned char pad[2]; unsigned int a2; unsigned int a4; unsigned int a6; int a8; };
struct envtext { unsigned char b0; unsigned char len; unsigned int pos; unsigned char text[1]; };
struct envicon { unsigned char pad[2]; unsigned char icon; unsigned int pos; };

extern unsigned char Scoop_CharGlyphMap[];
extern struct rect Scoop_StaticOp20_ClipBox;

extern void DrawBox(struct rect *, int);
extern void DrawLine(struct pt *, struct pt *, int);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
extern void DrawDesignBox(struct rect *, int, int);
extern void DrawIcons(struct pt *, long);

void Scoop_BoundOp04_DrawBoxByField(struct bfld *s)
{
	struct rect r;
	unsigned char v;
	struct cellbox *t;

	v = (*(unsigned char *)s->addr & s->mask) >> s->shift;
	t = (struct cellbox *)s->tbl + v;
	r.y0 = t->pos / 40;
	r.x0 = (t->pos % 40) << 3;
	r.y1 = t->h + r.y0;
	r.x1 = (t->w << 3) + r.x0;
	DrawBox(&r, 0xf5);
}

void Scoop_BoundOp08_DrawRectByField(struct bfld *s)
{
	struct rect r;
	unsigned char v;

	v = (*(unsigned char *)s->addr & s->mask) >> s->shift;
	r = ((struct rect *)s->tbl)[v];
	DrawBox(&r, 0xf5);
}

void Scoop_EnvCalc_Handler0(struct dsrc *s)
{
	struct rect r;

	r.y0 = s->a2 / 40;
	r.x0 = (s->a2 % 40) << 3;
	r.y1 = s->a6 + r.y0;
	r.x1 = (s->a4 << 3) + r.x0;
	DrawBox(&r, 0xf5);
}

void Scoop_EnvCalc_Handler1(struct envtext *s)
{
	char buf[256];
	struct pt pt;
	struct rect box;
	unsigned int v;
	unsigned char n;
	unsigned int i;

	box = Scoop_StaticOp20_ClipBox;
	v = s->pos;
	n = s->len - 4;
	pt.y = v / 40;
	pt.x = (v - pt.y * 40) << 3;
	for (i = 0; i < n; i++)
		buf[i] = Scoop_CharGlyphMap[s->text[i]];
	buf[i] = 0;
	DrawString(&box, &pt, buf, 6L, 0xff, 0xf5);
}

void Scoop_EnvCalc_Handler2(struct dsrc *s)
{
	struct pt b;
	struct pt a;

	a.x = s->a2;
	a.y = s->a4;
	b.x = s->a6;
	b.y = s->a8;
	DrawLine(&a, &b, 0xff);
}

void Scoop_EnvCalc_Handler3(struct envicon *s)
{
	struct rect r;
	struct pt pt;
	unsigned int icon;

	pt.y = s->pos / 40;
	pt.x = (s->pos % 40) << 3;
	icon = s->icon;
	r.x0 = pt.x - 2;
	r.x1 = pt.x + 25;
	r.y0 = pt.y - 2;
	r.y1 = pt.y + 25;
	DrawDesignBox(&r, 196, 240);
	DrawIcons(&pt, icon + 2);
}
