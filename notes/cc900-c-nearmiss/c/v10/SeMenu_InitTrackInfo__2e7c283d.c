/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_1m129a.c (2026-11-19-13-p6-r41)
   sha256 2e7c283d5e644432235f565d86f54863b4ad46525d24f4743f994933e9cc366e (tar-sha256); compiled at -O3 -Xr */
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
	p = rec;
	p[0] = 0x0f;
	p[1] = 0x0f;
	p[2] = m;
	SndParam_ApplyProgramChange(p);
	p = rec;
	b3 = p[3];
	b4 = p[4];
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
