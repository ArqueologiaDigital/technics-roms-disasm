/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_18m277b.c (2026-11-16-128-p6-r27)
   sha256 358fe2556b6e923294a16779b78931dbc973bb3c6955bcb6768569f1057a38ed (tar-sha256); compiled at -O3 -Xr */
extern void PanelEvent_Post(unsigned char *);
extern unsigned char __near ram_90f9;
extern unsigned char __near PART_SELECT;
void ExtDev_SndParam_Block14_Dual(unsigned char *e)
{
	unsigned char *q;

	q = e + 3;
	if (e[2] & *q) {
		ram_90f9 |= 2;
		e[0] = PART_SELECT;
		e[1] = 4;
		e[2] = 64;
		*q = 64;
		PanelEvent_Post(e);
	}
}
