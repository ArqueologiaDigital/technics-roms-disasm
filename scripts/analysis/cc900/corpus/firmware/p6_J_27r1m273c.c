/* lane_p6 helper J, round 27r1, form c: module 273 (ui/ui_widget_defs.s), the family LcdOn / LcdOff
   (families27_J, 2 x 26 B): the draw-queue wrapper of the built direct parts InitGraphics_SetupVRAM_Loop / LcdOn_Return
   (ui_widget_defs_m273_xr.c), each with its queued stub InitGraphics_SetupVRAM / LcdOff_Done2 (a tail `jr` into the
   direct part placed right after it).  Same idiom as p6_J_27r1m273a.c (Display_DeferOr*).
   Form c: `if (IsDrawTask() == 0) { queue } else Direct();` (form d: the other order).
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawQueue_Alloc DrawRing_Post IS_XSP_INSIDE_4K_REGION_AT_1C032 InitGraphics_SetupVRAM_Loop LcdOn_Return */
/* cc900-module: IsDrawTask InitGraphics_SetupVRAM LcdOff_Done2 */
/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */

struct wcmd { void (*fn)(struct wcmd *); };

extern int IsDrawTask(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern void InitGraphics_SetupVRAM_Loop(void);
extern void LcdOn_Return(void);
void InitGraphics_SetupVRAM(struct wcmd *q);
void LcdOff_Done2(struct wcmd *q);

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

void InitGraphics_SetupVRAM(struct wcmd *q)
{
	InitGraphics_SetupVRAM_Loop();
}

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

void LcdOff_Done2(struct wcmd *q)
{
	LcdOn_Return();
}
