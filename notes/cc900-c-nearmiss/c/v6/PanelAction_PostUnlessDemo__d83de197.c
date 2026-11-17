/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/audio_control_engine_m0.c (2026-11-17-6-p6-r30-staged)
   sha256 d83de197a2cee681f35c9a52640a3670baec69c5d3cade5f7a9b87824bc68bb3 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct pevt {
	unsigned char b0, b1, b2, b3;
};
extern void PanelEvent_FillSelectedPart(struct pevt *);
extern unsigned char __near CURRENT_MODE;
extern void PanelEvent_Post(struct pevt *e);
void PanelAction_PostUnlessDemo(struct pevt *e)
{
	if (CURRENT_MODE == 19) return;
	PanelEvent_FillSelectedPart(e);
	PanelEvent_Post(e);
	e++;
	PanelEvent_Post(e);
}
