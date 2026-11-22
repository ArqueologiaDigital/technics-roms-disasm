/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_22r2m128a.c (2026-11-21-21-p6-r66)
   sha256 88f0c3e7d1b4eecf8cbb9ba5a048a0ba0957637ab85d374b3c98a2febfb76b9f (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct rect { int x0; int y0; int x1; int y1; };
struct pt { int x, y; };
struct envicon { unsigned char pad[2]; unsigned char icon; unsigned int pos; };
extern void DrawDesignBox(struct rect *, int, int);
extern void DrawIcons(struct pt *, long);
void Scoop_EnvCalc_Handler3(struct envicon *s)
{
	struct pt pt;
	struct rect r;
	unsigned int icon;

	pt.y = s->pos / 40;
	pt.x = s->pos % 40 * 8;
	icon = s->icon;
	r.x0 = pt.x - 2;
	r.x1 = pt.x + 25;
	r.y0 = pt.y - 2;
	r.y1 = pt.y + 25;
	DrawDesignBox(&r, 196, 240);
	DrawIcons(&pt, (long)(icon + 2));
}
