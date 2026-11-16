/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_16m277.c (2026-11-16-118-p6-r23)
   sha256 2ea92cf6fde05451c8549862180b6e44e053c451e14ed3f919620fef8c438966 (tar-sha256); compiled at -O3 -Xr */
extern void PanelEvent_Post(unsigned char *);
extern unsigned char __near ram_90f9;
void ExtDev_SndParam_Block98_Var40(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 2;
	if (e[3] & e[2]) e[2] = 64;
	else e[2] = 0;
	e[3] = 64;
	PanelEvent_Post(e);
}
