/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_16m277.c (2026-11-16-118-p6-r23)
   sha256 2ea92cf6fde05451c8549862180b6e44e053c451e14ed3f919620fef8c438966 (tar-sha256); compiled at -O3 -Xr */
extern void PanelEvent_Post(unsigned char *);
extern int SndParam_LookupViaEncode(unsigned int, unsigned int);
extern unsigned char __near ram_90f9;
extern unsigned char __near ram_918d[];
extern unsigned char __near PART_SELECT;
void ExtDev_SndParam_ConfigAndWrite(unsigned char *e)
{
	if (!(e[3] & e[2])) return;
	ram_90f9 |= 2;
	e[0] = PART_SELECT;
	e[1] = 5;
	if (SndParam_LookupViaEncode(PART_SELECT, 93) == 0) e[2] = ram_918d[PART_SELECT];
	else e[2] = 0;
	e[3] = 127;
	PanelEvent_Post(e);
}
