/* Phase 6, lane_p6 helper M, round 5, module 129, form d: SeMenu_InitTrackInfo (alternative to p6_M_5m129c.c).
   The table chosen by a switch (cases written 2, 1 so V4.23 compares 1 first, as the ROM does), the first byte
   stored in each case, the second after the switch. */
/* cc900-module: SeMenu_LoadMasterPtr */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SndParam_ApplyProgramChange(unsigned char *);
extern void __cdecl SeMenu_DisplayPartValue(int, int, int);
extern unsigned char __near PANEL_PART_RT1[];
extern unsigned char __near PANEL_PART_RT2[];
extern unsigned char __near PANEL_PART_LEFT[];
extern void SeMenu_InitTrackInfo(void);

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
	switch (m) {
	case 2:
		p = PANEL_PART_LEFT;
		*p = b3;
		break;
	case 1:
		p = PANEL_PART_RT2;
		*p = b3;
		break;
	default:
		p = PANEL_PART_RT1;
		*p = b3;
		break;
	}
	p[1] = b4;
	SeMenu_DisplayPartValue(m, b3, b4);
}
