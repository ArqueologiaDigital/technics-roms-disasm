/* Functions of ui/drawing_primitives.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: DrawBitmapFile_Impl DrawDottedLine_Impl DrawMonoBitmap_Impl DrawQueue_Alloc DrawRing_Post DrawWall_DoCopy GraphicsRender_ProcessEntries GraphicsRender_RetStub IS_XSP_INSIDE_4K_REGION_AT_1C032 SetChangeRect */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
extern int DRAW_ENABLED;
struct bfcmd { void (*fn)(struct bfcmd *); struct pt p; long b; };
extern void DrawBitmapFile_Impl(struct pt *, long);
extern void DrawBitmapFile_QueuedExec(struct bfcmd *q);
struct wcmd { void (*fn)(struct wcmd *); };
extern void DrawWall_Deferred_Code(struct wcmd *q);
extern void DrawWall_DoCopy(void);

void DrawBitmapFile_QueuedExec(struct bfcmd *q)
{
	struct pt *p = &q->p;
	long b = q->b;

	if (DRAW_ENABLED != 0)
		DrawBitmapFile_Impl(p, b);
}

void DrawWall_Deferred_Code(struct wcmd *q)
{
	DrawWall_DoCopy();
}
