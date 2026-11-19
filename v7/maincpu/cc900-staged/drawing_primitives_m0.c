/* Functions of ui/drawing_primitives.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawBitmapFile_Impl DrawDottedLine_Impl DrawMonoBitmap_Impl DrawQueue_Alloc DrawRing_Post DrawWall_DoCopy GraphicsRender_ProcessEntries GraphicsRender_RetStub IS_XSP_INSIDE_4K_REGION_AT_1C032 SetChangeRect */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rect { int x0, y0, x1, y1; };
extern unsigned char *WALLPAPER_BITMAP;
extern unsigned char OFFSCREEN_BUFFER_1[];
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void SetChangeRect(struct rect *r);
extern void DrawWall_DoCopy(void);

void DrawWall_DoCopy(void)
{
	struct rect r;
	unsigned char *dst;
	unsigned char *src;

	src = WALLPAPER_BITMAP;
	dst = OFFSCREEN_BUFFER_1;
	Mem_Copy(dst, src, 0x9600);
	dst += 0x9600;
	src += 0x9600;
	Mem_Copy(dst, src, 0x9600);
	r.x0 = r.y0 = 0;
	r.x1 = 319;
	r.y1 = 239;
	SetChangeRect(&r);
}
