/* Phase 6, lane_p6 helper M, round 1, module 129 (audio/semenu_routines.s), form a.
   The SeMenu display-object builders: clear a 9-byte object in the frame, fill kind / master / fields, flush it.
   The ROM's clear loop has no entry test and computes the end once (`p = buf; e = p + 9; do ... while (p < e)`);
   helper J's for-loop (p6_J_5m129a, SeMenu_SetupDisplayObject_Alt1) gave V4.23's bottom-test loop with the end
   recomputed inside it, +13.  Address-taken locals: reverse declaration order (first declared highest).
   SeMenu_InitTrackInfo: the master part's two bytes from SndParam_ApplyProgramChange's record into the panel part
   table, then a __cdecl SeMenu_DisplayPartValue(master, b3, b4). */
/* cc900-name: SeMenu_SDO_Alt2_Cont21=SeMenu_SetupDisplayObject_Alt2_Continue_0x21 */
/* cc900-module: SeMenu_FlushDisplayObj SeMenu_LoadMasterPtr SeMenu_LoadObjEntries */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_FlushDisplayObj(unsigned char *);
extern void SndParam_ApplyProgramChange(unsigned char *);
extern void __cdecl SeMenu_DisplayPartValue(int, int, int);
extern unsigned char __near PANEL_PART_RT1[];
extern unsigned char __near PANEL_PART_RT2[];
extern unsigned char __near PANEL_PART_LEFT[];
extern void SeMenu_InitDisplayField(unsigned char a, unsigned char c);
extern void SeMenu_InitDisplayField_Alt(unsigned char a, unsigned char c, unsigned char x);
extern void SeMenu_SDO_Alt2_Cont21(unsigned char a);
extern void SeMenu_ClearDisplayBuffer(void);
extern void SeMenu_InitTrackInfo(void);

void SeMenu_InitDisplayField(unsigned char a, unsigned char c)
{
	unsigned char m;
	unsigned char buf[9];
	unsigned char obj;
	unsigned char *p;
	unsigned char *e;

	SeMenu_LoadObjEntries(&obj);
	p = buf;
	e = p + 9;
	do
		*p++ = 0;
	while (p < e);
	SeMenu_LoadMasterPtr(&m);
	p = buf;
	p[0] = 0x80;
	p[1] = m;
	e = &p[2];
	if (obj == 0)
		*e = 0x09;
	else
		*e = 0x12;
	p[3] = a - 1;
	p[4] = 1;
	p[5] = c;
	SeMenu_FlushDisplayObj(p);
}

void SeMenu_InitDisplayField_Alt(unsigned char a, unsigned char c, unsigned char x)
{
	unsigned char m;
	unsigned char buf[9];
	unsigned char obj;
	unsigned char *p;
	unsigned char *e;

	SeMenu_LoadObjEntries(&obj);
	p = buf;
	e = p + 9;
	do
		*p++ = 0;
	while (p < e);
	SeMenu_LoadMasterPtr(&m);
	p = buf;
	p[0] = 0x80;
	p[1] = m;
	e = &p[2];
	if (obj == 0)
		*e = 0x0a;
	else
		*e = 0x13;
	e = &p[3];
	*e = c - 1;
	*e <<= 4;
	*e += a - 1;
	p[4] = 1;
	p[5] = x;
	SeMenu_FlushDisplayObj(p);
}

void SeMenu_SDO_Alt2_Cont21(unsigned char a)
{
	unsigned char m;
	unsigned char buf[9];
	unsigned char *p;
	unsigned char *e;

	p = buf;
	e = p + 9;
	do
		*p++ = 0;
	while (p < e);
	SeMenu_LoadMasterPtr(&m);
	p = buf;
	p[0] = 0x88;
	p[1] = m;
	p[2] = 0;
	p[3] = 0;
	p[4] = a;
	p[5] = 0;
	SeMenu_FlushDisplayObj(p);
}

void SeMenu_ClearDisplayBuffer(void)
{
	unsigned char m;
	unsigned char buf[9];
	unsigned char *p;
	unsigned char *e;

	p = buf;
	e = p + 9;
	do
		*p++ = 0;
	while (p < e);
	SeMenu_LoadMasterPtr(&m);
	p = buf;
	p[0] = 0x88;
	p[1] = m;
	p[2] = 0x0d;
	p[3] = 0;
	p[4] = 0;
	p[5] = 0;
	SeMenu_FlushDisplayObj(p);
}

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
