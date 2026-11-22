/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawQueue_Alloc DrawRing_Post IS_XSP_INSIDE_4K_REGION_AT_1C032 InitGraphics_SetupVRAM InitGraphics_SetupVRAM_Loop IsDrawTask LcdOff_Done2 LcdOn_Return */   /* scripts/analysis/cc900/module_calls.py v10 */

struct wcmd { void (*fn)(struct wcmd *); };
extern int IsDrawTask(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern void LcdOn_Return(void);
void LcdOff_Done2(struct wcmd *q);
extern void LcdOff(void);
extern void LcdOff_Done2(struct wcmd *q);
extern void InitGraphics_SetupVRAM_Loop(void);
void InitGraphics_SetupVRAM(struct wcmd *q);
extern void LcdOn(void);
extern void InitGraphics_SetupVRAM(struct wcmd *q);

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void LcdOff(void)
{
	struct wcmd *q;

	if (IsDrawTask() == 0) {
		q = (struct wcmd *)DrawQueue_Alloc(sizeof(struct wcmd));
		q->fn = LcdOff_Done2;
		DrawRing_Post(q);
	} else
		LcdOn_Return();
}

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void LcdOn(void)
{
	struct wcmd *q;

	if (IsDrawTask() == 0) {
		q = (struct wcmd *)DrawQueue_Alloc(sizeof(struct wcmd));
		q->fn = InitGraphics_SetupVRAM;
		DrawRing_Post(q);
	} else
		InitGraphics_SetupVRAM_Loop();
}
