/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_1m129b.c (2026-11-19-13-p6-r41)
   sha256 1f9212f47e7485add79ffa97f84ddf95cae62e9ef1116d87df81197abbaa33fe (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SndParam_ApplyProgramChange(unsigned char *);
extern void __cdecl SeMenu_DisplayPartValue(int, int, int);
extern unsigned char __near PANEL_PART_RT1[];
extern unsigned char __near PANEL_PART_RT2[];
extern unsigned char __near PANEL_PART_LEFT[];
void SeMenu_InitTrackInfo(void)
{
	unsigned char rec[6];
	unsigned char m;
	unsigned char *p;
	unsigned char b3;
	unsigned char b4;

	SeMenu_LoadMasterPtr(&m);
	rec[0] = 0x0f;
	rec[1] = 0x0f;
	rec[2] = m;
	SndParam_ApplyProgramChange(rec);
	b3 = rec[3];
	b4 = rec[4];
	if (m == 1)
		p = PANEL_PART_RT2;
	else if (m == 2)
		p = PANEL_PART_LEFT;
	else
		p = PANEL_PART_RT1;
	p[0] = b3;
	p[1] = b4;
	SeMenu_DisplayPartValue(m, b3, b4);
}
