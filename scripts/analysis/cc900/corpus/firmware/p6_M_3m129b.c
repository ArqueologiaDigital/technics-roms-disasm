/* Phase 6, lane_p6 helper M, round 3, module 129, form b (alternative to p6_M_3m129a.c): the clear loop with the
   end pointer e declared before p (register choice of the loop: the ROM has p in XWA, e in XBC). */
/* cc900-name: SeMenu_SDO_Alt2_Cont21=SeMenu_SetupDisplayObject_Alt2_Continue_0x21 */
/* cc900-module: SeMenu_FlushDisplayObj SeMenu_LoadMasterPtr SeMenu_LoadObjEntries */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_FlushDisplayObj(unsigned char *);
extern void SeMenu_InitDisplayField(unsigned char a, unsigned char c);
extern void SeMenu_InitDisplayField_Alt(unsigned char a, unsigned char c, unsigned char x);
extern void SeMenu_SDO_Alt2_Cont21(unsigned char a);
extern void SeMenu_ClearDisplayBuffer(void);

void SeMenu_InitDisplayField(unsigned char a, unsigned char c)
{
	unsigned char m;
	unsigned char buf[9];
	unsigned char obj;
	unsigned char *e;
	unsigned char *p;

	SeMenu_LoadObjEntries(&obj);
	p = buf;
	e = p + 9;
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
	unsigned char *e;
	unsigned char *p;

	SeMenu_LoadObjEntries(&obj);
	p = buf;
	e = p + 9;
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

void SeMenu_SDO_Alt2_Cont21(unsigned char a)
{
	unsigned char m;
	unsigned char buf[9];
	unsigned char *e;
	unsigned char *p;

	p = buf;
	e = p + 9;
	do
		*p++ = 0;
	while (p < e);
	SeMenu_LoadMasterPtr(&m);
	buf[0] = 0x88;
	buf[1] = m;
	buf[2] = 0;
	buf[3] = 0;
	buf[4] = a;
	buf[5] = 0;
	SeMenu_FlushDisplayObj(buf);
}

void SeMenu_ClearDisplayBuffer(void)
{
	unsigned char m;
	unsigned char buf[9];
	unsigned char *e;
	unsigned char *p;

	p = buf;
	e = p + 9;
	do
		*p++ = 0;
	while (p < e);
	SeMenu_LoadMasterPtr(&m);
	buf[0] = 0x88;
	buf[1] = m;
	buf[2] = 0x0d;
	buf[3] = 0;
	buf[4] = 0;
	buf[5] = 0;
	SeMenu_FlushDisplayObj(buf);
}
