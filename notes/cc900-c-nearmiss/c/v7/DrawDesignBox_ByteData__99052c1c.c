/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/ui_window_procs_m0.c (2026-11-19-29-p6-r46)
   sha256 99052c1c97da6d5910d9cb030f67ab125bc2074be6015ad582ccf72bcd779d2c (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct pt { int x, y; };
extern int IsDrawTask(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
struct ddcmd { void (*fn)(struct ddcmd *); struct pt a; struct pt b; int c; };
extern void DrawDottedLine_Impl(struct pt *, struct pt *, int);
extern void DrawDesignBox_ByteData_Code(struct ddcmd *q);
void DrawDesignBox_ByteData(struct pt *a, struct pt *b, int c)
{
	struct ddcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawDottedLine_Impl(a, b, c);
	} else {
		q = (struct ddcmd *)DrawQueue_Alloc(sizeof(struct ddcmd));
		q->fn = DrawDesignBox_ByteData_Code;
		q->a = *a;
		q->b = *b;
		q->c = c;
		DrawRing_Post(q);
	}
}
