/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_18m277b.c (2026-11-16-128-p6-r27)
   sha256 358fe2556b6e923294a16779b78931dbc973bb3c6955bcb6768569f1057a38ed (tar-sha256); compiled at -O3 -Xr
   cc900-name: ExtDev_SndParam_DispWriteA8=ExtDev_SndParam_DispatchAndWriteA8 */
extern void PanelEvent_Post(unsigned char *);
extern int SndParam_LookupReadOnly(long);
extern unsigned char __near ram_90f9;
extern unsigned char __near CURRENT_MODE;
void ExtDev_SndParam_DispWriteA8(unsigned char *e)
{
	unsigned char m, *q;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	ram_90f9 |= 2;
	e[0] = 168;
	e[1] = 4;
	q = e + 3;
	if (e[2] & *q) {
		e[2] = 2;
		*q = 2;
		PanelEvent_Post(e);
	}
}
