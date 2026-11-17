/* Phase 6, lane_p6 helper G, round 14, module 273 (notes/cc900-phase6-2026-11-16/modules_v10.tsv), form a:
   ClipBlit_Direct (ui/ui_window_procs.s), new.  On the draw task's own stack (IS_XSP_INSIDE_4K_REGION_AT_1C032) it
   calls ClipBlit_Direct_Impl(p, n) at once; from any other task it queues a 10-byte draw command
   {ClipBlit_Direct_ParamBlock (the unpacking thunk), the point *p, n} with DrawQueue_Alloc / DrawRing_Post.
   Read from the hand assembly: p in XIZ, n kept in the frame (xsp+4), the command pointer left in XWA for
   DrawRing_Post; the point copied with two ldiw (a struct copy). */
/* cc900-module: ClipBlit_Direct_Impl DrawQueue_Alloc DrawRing_Post IS_XSP_INSIDE_4K_REGION_AT_1C032 */

struct pt { int x, y; };

extern int IS_XSP_INSIDE_4K_REGION_AT_1C032(void);
extern void ClipBlit_Direct_Impl(struct pt *, int);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void DrawRing_Post(unsigned char *);
extern void ClipBlit_Direct_ParamBlock(void);

void ClipBlit_Direct(struct pt *p, int n)
{
	unsigned char *q;

	if (IS_XSP_INSIDE_4K_REGION_AT_1C032() != 0)
		ClipBlit_Direct_Impl(p, n);
	else {
		q = DrawQueue_Alloc(10);
		*(void **)q = (void *)ClipBlit_Direct_ParamBlock;
		*(struct pt *)(q + 4) = *p;
		*(int *)(q + 8) = n;
		DrawRing_Post(q);
	}
}
