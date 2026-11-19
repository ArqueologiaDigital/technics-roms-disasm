/* Phase 6, lane_p6 helper M, round 5, module 129, form c: SeMenu_InitTrackInfo (run r43: 3m129a +39).  The code
   is the ROM's except the part-table pointer: V4.23 loads each address into XWA, copies it to XHL (p) and stores
   the second byte through XHL; the ROM keeps p in XWA.  This form: p declared before the other locals. */
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
