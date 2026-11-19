/* Functions of ui/ui_window_procs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: ChangePalette ChangeWall ChangeWallPalette DrawBitmapFile_Impl DrawDottedLine_Impl DrawMonoBitmap_Impl DrawQueue_Alloc DrawRing_Post DrawWall_DoCopy GraphicsRender_ProcessEntries GraphicsRender_RetStub IS_XSP_INSIDE_4K_REGION_AT_1C032 InitDrawTask LcdOn PaletteBankRotate_Impl SetChangeRect UpdateScreen */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
extern int DRAW_ENABLED;
struct ddcmd { void (*fn)(struct ddcmd *); struct pt a; struct pt b; int c; };
extern void DrawDottedLine_Impl(struct pt *, struct pt *, int);
extern void DrawDesignBox_ByteData_Code(struct ddcmd *q);
extern void PaletteBankRotate_Impl(void);
extern void PaletteBankRotate_Code(unsigned char *q);

void DrawDesignBox_ByteData_Code(struct ddcmd *q)
{
	struct pt *a = &q->a;
	struct pt *b = &q->b;
	int c = q->c;

	if (DRAW_ENABLED != 0)
		DrawDottedLine_Impl(a, b, c);
}

void PaletteBankRotate_Code(unsigned char *q)
{
	PaletteBankRotate_Impl();
}
