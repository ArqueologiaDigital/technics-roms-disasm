/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_19m277.c (2026-11-17-2-p6-r29)
   sha256 d9b53428790c9a61b25604fabbdfbd79fbdbea463ec38f02bfd1d983ad2be6e6 (tar-sha256); compiled at -O3 -Xr
   cc900-name: ExtDev_SndParam_DispWriteA8Alt=ExtDev_SndParam_DispatchAndWriteA8_Alt */
extern void PanelEvent_Post(unsigned char *);
extern int SndParam_LookupReadOnly(long);
extern unsigned char __near ram_90f9;
extern unsigned char __near CURRENT_MODE;
void ExtDev_SndParam_DispWriteA8Alt(unsigned char *e)
{
	unsigned char m, *p;
	register unsigned char *q;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	ram_90f9 |= 2;
	e[0] = 168;
	e[1] = 4;
	p = e + 2;
	q = e + 3;
	if (*p & *q) {
		*p = 1;
		*q = 1;
		PanelEvent_Post(e);
	}
}
