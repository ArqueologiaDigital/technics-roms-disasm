/* Functions of ui/drawing_primitives.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawBitmapFile_Impl DrawDottedLine_Impl DrawMonoBitmap_Impl DrawQueue_Alloc DrawRing_Post DrawWall_DoCopy GraphicsRender_ProcessEntries GraphicsRender_RetStub IS_XSP_INSIDE_4K_REGION_AT_1C032 SetChangeRect */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
extern int IsDrawTask(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
struct bfcmd { void (*fn)(struct bfcmd *); struct pt p; long b; };
extern void DrawBitmapFile_Impl(struct pt *, long);
extern void DrawBitmapFile_QueuedExec(struct bfcmd *q);
extern void DrawBitmapFile(struct pt *p, long b);
struct wcmd { void (*fn)(struct wcmd *); };
extern int ram_30450;
extern void Kernel_SemaSignal(int);
extern void Kernel_YieldRotate(int);
extern void DrawWall(void);
extern void DrawWall_Deferred_Code(struct wcmd *q);
extern void DrawWall_DoCopy(void);

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void DrawBitmapFile(struct pt *p, long b)
{
	struct bfcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawBitmapFile_Impl(p, b);
	} else {
		q = (struct bfcmd *)DrawQueue_Alloc(sizeof(struct bfcmd));
		q->fn = DrawBitmapFile_QueuedExec;
		q->p = *p;
		q->b = b;
		DrawRing_Post(q);
	}
}

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void DrawWall(void)
{
	struct wcmd *q;

	if (IsDrawTask() != 0) {
		ram_30450 = 1;
		DRAW_ENABLED = 1;
		DrawWall_DoCopy();
	} else {
		ram_30450 = 0;
		while (DRAW_ENABLED != 0) {
			Kernel_SemaSignal(1);
			Kernel_YieldRotate(3);
		}
		ram_30450 = 1;
		while (DRAW_ENABLED == 0) {
			Kernel_SemaSignal(1);
			Kernel_YieldRotate(3);
		}
		q = (struct wcmd *)DrawQueue_Alloc(sizeof(struct wcmd));
		q->fn = DrawWall_Deferred_Code;
		DrawRing_Post(q);
	}
}
