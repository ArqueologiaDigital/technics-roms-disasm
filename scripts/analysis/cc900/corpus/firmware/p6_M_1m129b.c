/* Phase 6, lane_p6 helper M, round 1, module 129 (audio/semenu_routines.s), form b (alternatives to p6_M_1m129a.c).
   InitDisplayField / _Alt: the object written through buf[] directly (no pointer locals for &buf[2] / &buf[3]);
   the clear loop as in form a.  InitTrackInfo: the table pointer chosen first, the two stores after the join. */
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
	e = buf + 9;
	do
		*p++ = 0;
	while (p < e);
	SeMenu_LoadMasterPtr(&m);
	buf[0] = 0x80;
	buf[1] = m;
	if (obj == 0)
		buf[2] = 0x09;
	else
		buf[2] = 0x12;
	buf[3] = a - 1;
	buf[4] = 1;
	buf[5] = c;
	SeMenu_FlushDisplayObj(buf);
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
	e = buf + 9;
	do
		*p++ = 0;
	while (p < e);
	SeMenu_LoadMasterPtr(&m);
	buf[0] = 0x80;
	buf[1] = m;
	if (obj == 0)
		buf[2] = 0x0a;
	else
		buf[2] = 0x13;
	buf[3] = c - 1;
	buf[3] <<= 4;
	buf[3] += a - 1;
	buf[4] = 1;
	buf[5] = x;
	SeMenu_FlushDisplayObj(buf);
}

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
