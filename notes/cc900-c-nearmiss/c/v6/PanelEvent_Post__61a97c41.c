/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/audio_control_engine_m277.c (2026-11-17-6-p6-r30-staged)
   sha256 61a97c411f6263a461b21c00f04a8781b18fb2912ca2aed411902468e25de489 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct pevt {
	unsigned char b0, b1, b2, b3;
};
extern struct pevt __near PANEL_EVENT_QUEUE[];
extern unsigned char __near ram_8dce;
void PanelEvent_Post(struct pevt *e)
{
	if (e->b0 == 0xff) return;
	if (ram_8dce <= 15) PANEL_EVENT_QUEUE[(unsigned int)ram_8dce++] = *e;
	e->b0 = 255;
}
