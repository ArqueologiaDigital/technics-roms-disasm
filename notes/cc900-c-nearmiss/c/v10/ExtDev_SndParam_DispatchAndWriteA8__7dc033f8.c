/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_19m277b.c (2026-11-17-2-p6-r29)
   sha256 7dc033f8148074a031d1e1217b09efa554269a58db87bceed83718799a0f00f3 (tar-sha256); compiled at -O3 -Xr
   cc900-name: ExtDev_SndParam_DispWriteA8=ExtDev_SndParam_DispatchAndWriteA8 */
extern void PanelEvent_Post(unsigned char *);
extern int SndParam_LookupReadOnly(long);
extern unsigned char __near ram_90f9;
extern unsigned char __near CURRENT_MODE;
void ExtDev_SndParam_DispWriteA8(unsigned char *e)
{
	unsigned char m, *q, *p;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	ram_90f9 |= 2;
	e[0] = 168;
	e[1] = 4;
	if (*(p = e + 2) & *(q = e + 3)) {
		*p = 2;
		*q = 2;
		PanelEvent_Post(e);
	}
}
