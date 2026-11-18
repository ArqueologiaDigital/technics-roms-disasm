/* Phase 6, lane_p6 helper J, round 5, module 129 (audio/semenu_routines.s, -O3 -Xr), form a:
   SeMenu_SetPartRecordBits and SeMenu_SetupDisplayObject_Alt1 (frame-only, no XIZ).
   SetPartRecordBits: set (on == 1) or clear the mask bits of the part's record byte in the panel part table chosen
   by the master selector (1 = RT2, 2 = LEFT, else RT1); the ROM computes all three addresses before branching --
   written as three pointer locals.  SetupDisplayObject_Alt1: clear a 9-byte display object, fill kind / master /
   value / 1 / *val / x and flush it. */
/* cc900-module: SeMenu_FlushDisplayObj SeMenu_LoadMasterPtr */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near PANEL_PART_RT1[];
extern unsigned char __near PANEL_PART_RT2[];
extern unsigned char __near PANEL_PART_LEFT[];
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_FlushDisplayObj(unsigned char *);

void SeMenu_SetPartRecordBits(unsigned char part, unsigned char mask, unsigned char on)
{
	unsigned char m;
	unsigned char *pl;
	unsigned char *p2;
	unsigned char *p1;

	SeMenu_LoadMasterPtr(&m);
	pl = &PANEL_PART_LEFT[part];
	p2 = &PANEL_PART_RT2[part];
	p1 = &PANEL_PART_RT1[part];
	if (on == 1) {
		if (m == 1)
			*p2 |= mask;
		else if (m == 2)
			*pl |= mask;
		else
			*p1 |= mask;
	} else {
		mask = ~mask;
		if (m == 1)
			*p2 &= mask;
		else if (m == 2)
			*pl &= mask;
		else
			*p1 &= mask;
	}
}

void SeMenu_SetupDisplayObject_Alt1(unsigned char kind, unsigned char v, unsigned char *val, unsigned char x)
{
	unsigned char m;
	unsigned char buf[9];
	unsigned char *p;
	unsigned char *q;
	unsigned char t;

	for (p = buf; p < buf + 9; )
		*p++ = 0;
	SeMenu_LoadMasterPtr(&m);
	q = &buf[2];
	*q = v;
	if (kind == 0)
		buf[0] = 0x8e;
	else if (kind == 1)
		buf[0] = 0x8f;
	else if (kind == 2) {
		buf[0] = 0x8f;
		t = *q;
		t |= 0x40;
		*q = t;
	} else
		buf[0] = 0x8d;
	buf[1] = m;
	buf[3] = 1;
	buf[4] = *val;
	buf[5] = x;
	SeMenu_FlushDisplayObj(buf);
}
