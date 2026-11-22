/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_22r2m128a.c (2026-11-21-21-p6-r66)
   sha256 88f0c3e7d1b4eecf8cbb9ba5a048a0ba0957637ab85d374b3c98a2febfb76b9f (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct rect { int x0; int y0; int x1; int y1; };
struct cellbox { unsigned int pos; unsigned int w; unsigned int h; };
struct bfld { unsigned char pad[2]; unsigned int addr; unsigned char mask; unsigned char shift; unsigned char b6;
	void *tbl; };
extern void DrawBox(struct rect *, int);
void Scoop_BoundOp04_DrawBoxByField(struct bfld *s)
{
	struct rect r;
	unsigned char v;
	struct cellbox *t;

	v = (*(unsigned char *)s->addr & s->mask) >> s->shift;
	t = &((struct cellbox *)s->tbl)[v];
	r.y0 = t->pos / 40;
	r.x0 = t->pos % 40 * 8;
	r.y1 = r.y0 + t->h;
	r.x1 = r.x0 + t->w * 8;
	DrawBox(&r, 0xf5);
}
