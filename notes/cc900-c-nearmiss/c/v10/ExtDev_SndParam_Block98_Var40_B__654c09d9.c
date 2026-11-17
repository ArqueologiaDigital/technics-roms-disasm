/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_17m277b.c (2026-11-16-123-p6-r25)
   sha256 654c09d99a5ec49367bf46c872a3d17ae11010d8355594e8f87b5222da5852f1 (tar-sha256); compiled at -Xr */
extern void PanelEvent_Post(unsigned char *);
extern unsigned char __near ram_90f9;
void ExtDev_SndParam_Block98_Var40_B(unsigned char *e)
{
	unsigned char *q, *p;

	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 11;
	p = e + 2;
	q = e + 3;
	if (*p & *q) *p = 64;
	else *p = 0;
	*q = 64;
	PanelEvent_Post(e);
}
