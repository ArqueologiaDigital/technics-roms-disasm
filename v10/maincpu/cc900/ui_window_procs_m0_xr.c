/* Functions of ui/ui_window_procs.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

#define EVT_GET_BITMAP_DATA   0x1e000a1L
#define EVT_GET_BITMAP_WIDTH  0x1e000a2L
#define EVT_GET_BITMAP_HEIGHT 0x1e000a3L
extern unsigned char UserBitmapCheck_Bitmap24x24[];

long UserBitmapCheck(long obj, long evt, long p)
{
	switch (evt) {
	case EVT_GET_BITMAP_DATA:
		return (long)UserBitmapCheck_Bitmap24x24;
	case EVT_GET_BITMAP_WIDTH:
	case EVT_GET_BITMAP_HEIGHT:
		return 24;
	}
	return 0;
}

/* cc900-module: ClipBlit_Replace_Impl ColorBlit2_Impl DrawBitmapSPFast_Impl DrawDesignBox_Impl DrawDottedLineWithMode_Impl DrawFrame_Impl DrawIcons_Impl DrawQueue_Alloc DrawRing_Post Gfx_BlitDirtyRegions IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct pt { int x, y; };
struct cmd_pt_i { void *fn; struct pt p; int n; };
extern void ClipBlit_Replace_Impl(struct pt *, int);
extern void ClipBlit_Replace_ParamBlock(struct cmd_pt_i *q);
struct rect { int x0, y0, x1, y1; };
struct cmd_r_ii { void *fn; struct rect r; int a; int b; };
extern int DRAW_ENABLED;
extern void DrawDesignBox_Impl(struct rect *, int, int);
extern void DrawDesignBox_QueueCallback(struct cmd_r_ii *q);

void ClipBlit_Replace_ParamBlock(struct cmd_pt_i *q)
{
	ClipBlit_Replace_Impl(&q->p, q->n);
}
void DrawDesignBox_QueueCallback(struct cmd_r_ii *q)
{
	struct rect *r;
	int a;
	int b;

	r = &q->r;
	a = q->a;
	b = q->b;
	if (DRAW_ENABLED != 0)
		DrawDesignBox_Impl(r, a, b);
}

/* cc900-module: ChangePalette ChangeWall ChangeWallPalette DrawBitmapFile_Impl DrawDottedLine_Impl DrawMonoBitmap_Impl DrawWall_DoCopy GraphicsRender_ProcessEntries GraphicsRender_RetStub InitDrawTask LcdOn PaletteBankRotate_Impl SetChangeRect UpdateScreen */
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

/* cc900-module: ChangePalette_Impl ChangeWallPalette_Impl ChangeWall_Impl Display_FillPalBandFromEnt_Impl Display_FillPaletteBandFromEntry_Impl IsXspInDrawStack */
struct icmd { void (*fn)(struct icmd *); unsigned int w; };
extern void ChangePalette_Impl(unsigned int);
void ChangePalette_QueueCallback(struct icmd *q);
extern void ChangePalette_QueueCallback(struct icmd *q);
extern void ChangeWallPalette_Impl(unsigned int);
void ChangeWallPalette_QueueCallback(struct icmd *q);
extern void ChangeWallPalette_QueueCallback(struct icmd *q);
extern void ChangeWall_Impl(unsigned int);
void ChangeWall_QueueCallback(struct icmd *q);
extern void ChangeWall_QueueCallback(struct icmd *q);

void ChangePalette_QueueCallback(struct icmd *q)
{
	ChangePalette_Impl(q->w);
}
void ChangeWallPalette_QueueCallback(struct icmd *q)
{
	ChangeWallPalette_Impl(q->w);
}
void ChangeWall_QueueCallback(struct icmd *q)
{
	ChangeWall_Impl(q->w);
}
