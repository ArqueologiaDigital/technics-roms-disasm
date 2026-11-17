/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/audio_control_engine_m277.c (2026-11-17-6-p6-r30-staged)
   sha256 a996d1492d88c5398faac81a69fddd67b2372701faaa142e67230e6fefca7133 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct pevt {
	unsigned char b0, b1, b2, b3;
};
extern struct pevt __near PANEL_EVENT_QUEUE[];
extern unsigned char __near ram_8df2;
void PanelEvent_Post(struct pevt *e)
{
	if (e->b0 == 0xff) return;
	if (ram_8df2 <= 15) PANEL_EVENT_QUEUE[(unsigned int)ram_8df2++] = *e;
	e->b0 = 255;
}
