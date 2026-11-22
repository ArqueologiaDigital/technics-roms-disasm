/* Functions of ui/ui_window_procs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ChangePalette_Impl ChangeWallPalette_Impl ChangeWall_Impl Display_FillPalBandFromEnt_Impl Display_FillPaletteBandFromEntry_Impl DrawQueue_Alloc DrawRing_Post IS_XSP_INSIDE_4K_REGION_AT_1C032 IsXspInDrawStack */   /* scripts/analysis/cc900/module_calls.py v10 */

struct icmd { void (*fn)(struct icmd *); unsigned int w; };
extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern void ChangePalette_Impl(unsigned int);
void ChangePalette_QueueCallback(struct icmd *q);
extern void ChangePalette(unsigned int w);
extern void ChangePalette_QueueCallback(struct icmd *q);
extern void ChangeWall_Impl(unsigned int);
void ChangeWall_QueueCallback(struct icmd *q);
extern void ChangeWall(unsigned int w);
extern void ChangeWall_QueueCallback(struct icmd *q);
extern void ChangeWallPalette_Impl(unsigned int);
void ChangeWallPalette_QueueCallback(struct icmd *q);
extern void ChangeWallPalette(unsigned int w);
extern void ChangeWallPalette_QueueCallback(struct icmd *q);

/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
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

/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
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

/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
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
