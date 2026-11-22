/* lane_p6 helper I, round 26r1, form a: module 273, the draw-queue wrappers with one int argument and no
   DRAW_ENABLED test (family of 4 x 44 B: ChangeWall, ChangeWallPalette, ChangePalette of ui/ui_window_procs.s and
   Display_FillPaletteBandFromEntry of display/graphics_text_vga.s), each with its queued stub (`ld wa,(xwa+4)`, a
   tail jump into the _Impl placed right after it).  The draw-queue idiom of the built drawing_primitives_m273.c,
   command record written through a struct.
   cc900-options: -O3 -Xr
*/
/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
/* cc900-name: Display_FillPalBandFromEntry=Display_FillPaletteBandFromEntry */
/* cc900-name: Display_FillPalBandFromEnt_Impl=Display_FillPaletteBandFromEntry_Impl */
/* cc900-module: ChangePalette_Impl ChangeWallPalette_Impl ChangeWall_Impl Display_FillPaletteBandFromEntry_Impl DrawQueue_Alloc DrawRing_Post IS_XSP_INSIDE_4K_REGION_AT_1C032 */   /* scripts/analysis/cc900/module_calls.py v10 */
/* cc900-module: IsXspInDrawStack Display_FillPalBandFromEnt_Impl */

struct icmd { void (*fn)(struct icmd *); unsigned int w; };

extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);

extern void ChangeWall_Impl(unsigned int);
extern void ChangeWallPalette_Impl(unsigned int);
extern void ChangePalette_Impl(unsigned int);
extern void Display_FillPalBandFromEnt_Impl(unsigned int);
void ChangeWall_QueueCallback(struct icmd *q);
void ChangeWallPalette_QueueCallback(struct icmd *q);
void ChangePalette_QueueCallback(struct icmd *q);
void GraphicsRender_ByteData_Code(struct icmd *q);

void ChangeWall(unsigned int w)
{
	struct icmd *q;

	if (IsXspInDrawStack() != 0)
		ChangeWall_Impl(w);
	else {
		q = (struct icmd *)DrawQueue_Alloc(6);
		q->fn = ChangeWall_QueueCallback;
		q->w = w;
		DrawRing_Post(q);
	}
}

void ChangeWall_QueueCallback(struct icmd *q)
{
	ChangeWall_Impl(q->w);
}

void ChangeWallPalette(unsigned int w)
{
	struct icmd *q;

	if (IsXspInDrawStack() != 0)
		ChangeWallPalette_Impl(w);
	else {
		q = (struct icmd *)DrawQueue_Alloc(6);
		q->fn = ChangeWallPalette_QueueCallback;
		q->w = w;
		DrawRing_Post(q);
	}
}

void ChangeWallPalette_QueueCallback(struct icmd *q)
{
	ChangeWallPalette_Impl(q->w);
}

void ChangePalette(unsigned int w)
{
	struct icmd *q;

	if (IsXspInDrawStack() != 0)
		ChangePalette_Impl(w);
	else {
		q = (struct icmd *)DrawQueue_Alloc(6);
		q->fn = ChangePalette_QueueCallback;
		q->w = w;
		DrawRing_Post(q);
	}
}

void ChangePalette_QueueCallback(struct icmd *q)
{
	ChangePalette_Impl(q->w);
}

void Display_FillPalBandFromEntry(unsigned int w)
{
	struct icmd *q;

	if (IsXspInDrawStack() != 0)
		Display_FillPalBandFromEnt_Impl(w);
	else {
		q = (struct icmd *)DrawQueue_Alloc(6);
		q->fn = GraphicsRender_ByteData_Code;
		q->w = w;
		DrawRing_Post(q);
	}
}

void GraphicsRender_ByteData_Code(struct icmd *q)
{
	Display_FillPalBandFromEnt_Impl(q->w);
}
