/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/audio_control_engine_m277.c (2026-11-17-6-p6-r30-staged)
   sha256 2d1c65634fcf0ddef037aa8df2ea764e5daa9a318c55c5e7a3e6d5b92e9a3b66 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct pevt {
	unsigned char b0, b1, b2, b3;
};
extern struct pevt __near PANEL_EVENT_QUEUE[];
extern unsigned char __near ram_8e8e;
void PanelEvent_Post(struct pevt *e)
{
	if (e->b0 == 0xff) return;
	if (ram_8e8e <= 15) PANEL_EVENT_QUEUE[(unsigned int)ram_8e8e++] = *e;
	e->b0 = 255;
}
