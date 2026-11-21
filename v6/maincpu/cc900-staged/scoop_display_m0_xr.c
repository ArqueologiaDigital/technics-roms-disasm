/* Functions of display/scoop_display.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct rect { int x0; int y0; int x1; int y1; };
struct dsrc { unsigned char pad[2]; unsigned int a2; unsigned int a4; unsigned int a6; int a8; };
extern void DrawBox(struct rect *, int);
extern void Scoop_EnvCalc_Handler0(struct dsrc *s);

void Scoop_EnvCalc_Handler0(struct dsrc *s)
{
	struct rect r;

	r.y0 = s->a2 / 40;
	r.x0 = s->a2 % 40 * 8;
	r.y1 = r.y0 + s->a6;
	r.x1 = r.x0 + s->a4 * 8;
	DrawBox(&r, 0xf5);
}
