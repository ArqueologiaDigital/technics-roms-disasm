/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of v7/ui_window_procs.c (2026-11-16-55-p6-r10)
   sha256 da9d1048d705ce8f9c3275967b14471e1632ac5accef3d6477736e47ad4a5b20 (tar-sha256); compiled at -O3 -Xr */
/* Functions of ui/ui_window_procs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

#define EVT_DRAW              0x1c0000dL

struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
struct vinst { unsigned char pad[14]; struct rect r; long l22; long l26; int i30; };

long BitmapProc(long obj, long evt, long p)
{
	struct pt pt;
	struct vinst *h;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	pt.x = h->r.x1;
	pt.y = h->r.y1;
	DrawBitmap(&pt, (unsigned char *)h->l22);
	return 0;
}
