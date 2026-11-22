/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_22r2m128a.c (2026-11-21-21-p6-r66)
   sha256 88f0c3e7d1b4eecf8cbb9ba5a048a0ba0957637ab85d374b3c98a2febfb76b9f (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct pt { int x, y; };
struct dsrc { unsigned char pad[2]; unsigned int a2; unsigned int a4; unsigned int a6; int a8; };
extern void DrawLine(struct pt *, struct pt *, int);
void Scoop_EnvCalc_Handler2(struct dsrc *s)
{
	struct pt a;
	struct pt b;

	a.x = s->a2;
	a.y = s->a4;
	b.x = s->a6;
	b.y = s->a8;
	DrawLine(&a, &b, 0xff);
}
