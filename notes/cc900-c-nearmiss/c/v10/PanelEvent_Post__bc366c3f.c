/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_20m277b.c (2026-11-17-2-p6-r29)
   sha256 bc366c3f1191897c3cfe0d9d6a42c5399b67554bceb93f4fb12c1e5f1f094a2f (tar-sha256); compiled at -O3 -Xr */
struct pevt {
	unsigned char b0, b1, b2, b3;
};
extern struct pevt __near PANEL_EVENT_QUEUE[];
extern unsigned char __near ram_8e8e;
void PanelEvent_Post(struct pevt *e)
{
	unsigned char n;
	unsigned int i;

	if (e->b0 == 0xff) return;
	n = ram_8e8e;
	if (n <= 15) {
		i = n++;
		ram_8e8e = n;
		PANEL_EVENT_QUEUE[i] = *e;
	}
	e->b0 = 255;
}
