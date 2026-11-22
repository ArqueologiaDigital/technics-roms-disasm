/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_22r2m128b.c (2026-11-21-21-p6-r66)
   sha256 3863ed967c5eaa19a3b9cf699f5cf978a672a7140df9c4e78869cf8f6a7d3272 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct rect { int x0; int y0; int x1; int y1; };
struct dsrc { unsigned char pad[2]; unsigned int a2; unsigned int a4; unsigned int a6; int a8; };
extern void DrawBox(struct rect *, int);
void Scoop_EnvCalc_Handler0(struct dsrc *s)
{
	struct rect r;

	r.y0 = s->a2 / 40;
	r.x0 = (s->a2 % 40) << 3;
	r.y1 = s->a6 + r.y0;
	r.x1 = (s->a4 << 3) + r.x0;
	DrawBox(&r, 0xf5);
}
