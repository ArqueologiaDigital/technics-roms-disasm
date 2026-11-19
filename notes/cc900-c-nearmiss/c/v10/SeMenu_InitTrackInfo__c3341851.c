/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_5m129c.c (2026-11-19-29-p6-r46)
   sha256 c33418515d5ca18514d86fb3e1de99de33a2d4f212076a55042a642065317c53 (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SndParam_ApplyProgramChange(unsigned char *);
extern void __cdecl SeMenu_DisplayPartValue(int, int, int);
extern unsigned char __near PANEL_PART_RT1[];
extern unsigned char __near PANEL_PART_RT2[];
extern unsigned char __near PANEL_PART_LEFT[];
void SeMenu_InitTrackInfo(void)
{
	unsigned char *p;
	unsigned char rec[6];
	unsigned char m;
	unsigned char b3;
	unsigned char b4;

	SeMenu_LoadMasterPtr(&m);
	rec[0] = 0x0f;
	rec[1] = 0x0f;
	rec[2] = m;
	SndParam_ApplyProgramChange(rec);
	b3 = rec[3];
	b4 = rec[4];
	if (m == 1) {
		p = PANEL_PART_RT2;
		*p = b3;
	} else if (m == 2) {
		p = PANEL_PART_LEFT;
		*p = b3;
	} else {
		p = PANEL_PART_RT1;
		*p = b3;
	}
	p[1] = b4;
	SeMenu_DisplayPartValue(m, b3, b4);
}
