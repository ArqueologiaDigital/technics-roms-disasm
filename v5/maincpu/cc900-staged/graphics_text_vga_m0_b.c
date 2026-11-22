/* Functions of display/graphics_text_vga.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Display_DeferOrDrawWall_Code Display_DeferOrDrawWall_Direct Display_DeferOrUpdScreen_Code Display_DeferOrUpdScreen_Direct Display_DeferOrUpdateScreen_Direct DrawQueue_Alloc DrawRing_Post DrawWall IS_XSP_INSIDE_4K_REGION_AT_1C032 IsDrawTask SetNeedUpdate UpdateScreen */   /* scripts/analysis/cc900/module_calls.py v10 */

struct wcmd { void (*fn)(struct wcmd *); };
extern void SetNeedUpdate(int);
extern void DrawWall(void);
extern int ram_3ef8e;
void Display_DeferOrDrawWall_Direct(void);
void Display_DeferOrUpdScreen_Code(struct wcmd *q);
extern void Display_DeferOrDrawWall_Direct(void);
extern void Display_DeferOrUpdScreen_Code(struct wcmd *q);
extern void UpdateScreen(void);
extern void Display_DeferOrUpdScreen_Direct(void); 
/* cc900-name: Display_DeferOrUpdScreen_Code=Display_DeferOrUpdateScreen_Code */
void Display_DeferOrDrawWall_Direct(void)
{
	ram_3ef8e = 0;
	SetNeedUpdate(0);
	DrawWall();
}

/* cc900-name: Display_DeferOrUpdScreen_Direct=Display_DeferOrUpdateScreen_Direct */
void Display_DeferOrUpdScreen_Direct(void)
{
	ram_3ef8e = 1;
	SetNeedUpdate(1);
	UpdateScreen();
}
