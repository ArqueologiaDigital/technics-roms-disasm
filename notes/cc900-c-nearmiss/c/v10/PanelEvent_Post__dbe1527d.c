/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_20m277.c (2026-11-17-2-p6-r29)
   sha256 dbe1527d24742a811359627590549ff2364cf92df3a6840607a1743db7e1e142 (tar-sha256); compiled at -O3 -XS -Xr */
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
