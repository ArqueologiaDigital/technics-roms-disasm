/* Functions of ui/ui_window_procs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: GetEditSwPoint */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rect { int x1, y1, x2, y2; };
extern void DrawFrame(struct rect *r, int n);
extern void DrawDesignFrame(struct rect *, int, int, int);
extern void DrawDesignFrame(struct rect *r, int style, int thick, int color);

void DrawDesignFrame(struct rect *r, int style, int thick, int color)
{
    struct rect b;
    register long i;

    b = *r;
    if (style == 1)
        for (i = 0; i < thick; i++) {
            DrawFrame(&b, color);
            b.y1++;
            b.y2--;
            b.x1++;
            b.x2--;
        }
}
