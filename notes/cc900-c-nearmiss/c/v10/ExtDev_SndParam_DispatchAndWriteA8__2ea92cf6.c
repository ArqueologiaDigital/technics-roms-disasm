/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_16m277.c (2026-11-16-118-p6-r23)
   sha256 2ea92cf6fde05451c8549862180b6e44e053c451e14ed3f919620fef8c438966 (tar-sha256); compiled at -O3 -Xr
   cc900-name: ExtDev_SndParam_DispWriteA8=ExtDev_SndParam_DispatchAndWriteA8 */
extern void PanelEvent_Post(unsigned char *);
extern int SndParam_LookupReadOnly(long);
extern unsigned char __near ram_90f9;
extern unsigned char __near CURRENT_MODE;
void ExtDev_SndParam_DispWriteA8(unsigned char *e)
{
	switch (CURRENT_MODE) {
	case 19: case 3: case 17: case 14: case 15: case 16:
		return;
	}
	if (SndParam_LookupReadOnly(192) == 1) return;
	ram_90f9 |= 2;
	e[0] = 168;
	e[1] = 4;
	if (!(e[3] & e[2])) return;
	e[2] = 2;
	e[3] = 2;
	PanelEvent_Post(e);
}
