/* lane_p6 helper J, round 27r1, form b: module 273 (display/graphics_text_vga.s), the family
   Display_DeferOrUpdateScreen / Display_DeferOrDrawWall (families27_J, 2 x 41 B), the draw-queue idiom of the built
   DrawWall / DrawWall_Deferred_Code: on the draw task the direct part (0x3ef92 = 1 / 0, SetNeedUpdate(1 / 0), tail
   jump to UpdateScreen / DrawWall), else a 4-byte command {Code} posted to the draw ring.  Each stretch holds three
   C functions in ROM order: the wrapper, its queued stub `Code` (a tail `jr` into the direct part) and `Direct`.
   The wrapper's `jr nz, Direct` would be V4.23 threading the else branch's tail jump.
   Form b: `if (IsDrawTask() != 0) Direct(); else { queue }` (the built DrawWall's order).
   cc900-options: -O3 -Xr
*/
/* cc900-module: Display_DeferOrDrawWall_Direct Display_DeferOrUpdateScreen_Direct DrawQueue_Alloc DrawRing_Post DrawWall IS_XSP_INSIDE_4K_REGION_AT_1C032 SetNeedUpdate UpdateScreen */   /* scripts/analysis/cc900/module_calls.py v10 */
/* cc900-module: IsDrawTask Display_DeferOrUpdScreen_Code Display_DeferOrUpdScreen_Direct Display_DeferOrDrawWall_Code */
/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
/* cc900-name: Display_DeferOrUpdScreen_Code=Display_DeferOrUpdateScreen_Code */
/* cc900-name: Display_DeferOrUpdScreen_Direct=Display_DeferOrUpdateScreen_Direct */

struct wcmd { void (*fn)(struct wcmd *); };

extern int IsDrawTask(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern void SetNeedUpdate(int);
extern void UpdateScreen(void);
extern void DrawWall(void);
extern int ram_3ef92;
void Display_DeferOrDrawWall_Code(struct wcmd *q);
void Display_DeferOrDrawWall_Direct(void);
void Display_DeferOrUpdScreen_Code(struct wcmd *q);
void Display_DeferOrUpdScreen_Direct(void);

void Display_DeferOrDrawWall(void)
{
	struct wcmd *q;

	if (IsDrawTask() != 0)
		Display_DeferOrDrawWall_Direct();
	else {
		q = (struct wcmd *)DrawQueue_Alloc(sizeof(struct wcmd));
		q->fn = Display_DeferOrDrawWall_Code;
		DrawRing_Post(q);
	}
}

void Display_DeferOrDrawWall_Code(struct wcmd *q)
{
	Display_DeferOrDrawWall_Direct();
}

void Display_DeferOrDrawWall_Direct(void)
{
	ram_3ef92 = 0;
	SetNeedUpdate(0);
	DrawWall();
}

void Display_DeferOrUpdateScreen(void)
{
	struct wcmd *q;

	if (IsDrawTask() != 0)
		Display_DeferOrUpdScreen_Direct();
	else {
		q = (struct wcmd *)DrawQueue_Alloc(sizeof(struct wcmd));
		q->fn = Display_DeferOrUpdScreen_Code;
		DrawRing_Post(q);
	}
}

void Display_DeferOrUpdScreen_Code(struct wcmd *q)
{
	Display_DeferOrUpdScreen_Direct();
}

void Display_DeferOrUpdScreen_Direct(void)
{
	ram_3ef92 = 1;
	SetNeedUpdate(1);
	UpdateScreen();
}
