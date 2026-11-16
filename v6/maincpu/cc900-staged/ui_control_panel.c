/* Functions of ui/ui_control_panel.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct box { int x0, y0, x1, y1; };
struct pt { int x, y; };

void GetBoxCenter(struct box *b, struct pt *c)
{
	c->x = b->x0 + (b->x1 - b->x0 + 1) / 2;
	c->y = b->y0 + (b->y1 - b->y0 + 1) / 2;
}
