/* lane_p6 helper I, round 26r1, form b: as form a (module 273, ChangeWall / ChangeWallPalette / ChangePalette /
   Display_FillPaletteBandFromEntry and their queued stubs), but the command record written through a byte pointer
   like the built DrawFrame (`*(void **)q = ...; *(int *)(q + 4) = w;`), and int arguments.
   cc900-options: -O3 -Xr
*/
/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
/* cc900-name: Display_FillPalBandFromEntry=Display_FillPaletteBandFromEntry */
/* cc900-name: Display_FillPalBandFromEnt_Impl=Display_FillPaletteBandFromEntry_Impl */
/* cc900-module: ChangePalette_Impl ChangeWallPalette_Impl ChangeWall_Impl Display_FillPaletteBandFromEntry_Impl DrawQueue_Alloc DrawRing_Post IS_XSP_INSIDE_4K_REGION_AT_1C032 */   /* scripts/analysis/cc900/module_calls.py v10 */
/* cc900-module: IsXspInDrawStack Display_FillPalBandFromEnt_Impl */

extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);

extern void ChangeWall_Impl(int);
extern void ChangeWallPalette_Impl(int);
extern void ChangePalette_Impl(int);
extern void Display_FillPalBandFromEnt_Impl(int);
void ChangeWall_QueueCallback(unsigned char *q);
void ChangeWallPalette_QueueCallback(unsigned char *q);
void ChangePalette_QueueCallback(unsigned char *q);
void GraphicsRender_ByteData_Code(unsigned char *q);

void ChangeWall(int w)
{
	unsigned char *q;

	if (IsXspInDrawStack() != 0)
		ChangeWall_Impl(w);
	else {
		q = DrawQueue_Alloc(6);
		*(void **)q = (void *)ChangeWall_QueueCallback;
		*(int *)(q + 4) = w;
		DrawRing_Post(q);
	}
}

void ChangeWall_QueueCallback(unsigned char *q)
{
	ChangeWall_Impl(*(int *)(q + 4));
}

void ChangeWallPalette(int w)
{
	unsigned char *q;

	if (IsXspInDrawStack() != 0)
		ChangeWallPalette_Impl(w);
	else {
		q = DrawQueue_Alloc(6);
		*(void **)q = (void *)ChangeWallPalette_QueueCallback;
		*(int *)(q + 4) = w;
		DrawRing_Post(q);
	}
}

void ChangeWallPalette_QueueCallback(unsigned char *q)
{
	ChangeWallPalette_Impl(*(int *)(q + 4));
}

void ChangePalette(int w)
{
	unsigned char *q;

	if (IsXspInDrawStack() != 0)
		ChangePalette_Impl(w);
	else {
		q = DrawQueue_Alloc(6);
		*(void **)q = (void *)ChangePalette_QueueCallback;
		*(int *)(q + 4) = w;
		DrawRing_Post(q);
	}
}

void ChangePalette_QueueCallback(unsigned char *q)
{
	ChangePalette_Impl(*(int *)(q + 4));
}

void Display_FillPalBandFromEntry(int w)
{
	unsigned char *q;

	if (IsXspInDrawStack() != 0)
		Display_FillPalBandFromEnt_Impl(w);
	else {
		q = DrawQueue_Alloc(6);
		*(void **)q = (void *)GraphicsRender_ByteData_Code;
		*(int *)(q + 4) = w;
		DrawRing_Post(q);
	}
}

void GraphicsRender_ByteData_Code(unsigned char *q)
{
	Display_FillPalBandFromEnt_Impl(*(int *)(q + 4));
}
