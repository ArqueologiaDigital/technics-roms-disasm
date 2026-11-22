/* Functions of display/graphics_text_vga.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ChangePalette_Impl ChangeWallPalette_Impl ChangeWall_Impl Display_FillPalBandFromEnt_Impl Display_FillPaletteBandFromEntry_Impl DrawQueue_Alloc DrawRing_Post IS_XSP_INSIDE_4K_REGION_AT_1C032 IsXspInDrawStack */   /* scripts/analysis/cc900/module_calls.py v10 */

struct icmd { void (*fn)(struct icmd *); unsigned int w; };
extern void Display_FillPalBandFromEnt_Impl(unsigned int);
void GraphicsRender_ByteData_Code(struct icmd *q);
extern void GraphicsRender_ByteData_Code(struct icmd *q);

/* cc900-name: Display_FillPalBandFromEnt_Impl=Display_FillPaletteBandFromEntry_Impl */
void GraphicsRender_ByteData_Code(struct icmd *q)
{
	Display_FillPalBandFromEnt_Impl(q->w);
}
