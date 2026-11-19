/* lane_p6 helper N, round 4, form a: module 129 (audio/semenu_routines.s), retry of p6_N_2m129a / b.
   SeMenu_StepParamFieldAndSend (p6-r43 O3Xr: +29): the only difference was an extra `extz hl` before pushing the
   step mask to SeMenu_RegisterElement_Extended, whose 4th parameter was unsigned char in round 2; it is unsigned
   int here (as the built prototype has it; the callee reads only its low byte).
   SeMenu_RegisterElement_Extended (p6-r43: +13): the clear loop had the pointer and the end in each other's
   register (the ROM: pointer XWA, end XBC): the end declared first; the flags byte built in a char local
   (the ROM keeps 0x80 in A, stores it, sets bit 3 in A and stores again).
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeMenu_BitShiftMask SeMenu_FlushDisplayObj SeMenu_LoadMasterPtr SeMenu_LoadObjEntries SeMenu_RegisterElement_Extended SeMenu_SetObjectFlags SeMenu_SetupDisplayObject_Alt1 SeMenu_StepParamField SeMenu_StorePartParam */

struct seobj { unsigned char flags, master, field, one, value, mask, x6, x7, x8; };
extern void SeMenu_LoadMasterPtr(unsigned char *m);
extern void SeMenu_SetObjectFlags(int);
extern void SeMenu_FlushDisplayObj(struct seobj *);
extern int SeMenu_RegisterElement_Extended(unsigned char id, unsigned char field, unsigned char *v, unsigned int mask);

int SeMenu_RegisterElement_Extended(unsigned char id, unsigned char field, unsigned char *v, unsigned int mask)
{
	unsigned char m;
	struct seobj o;
	unsigned char *e;
	unsigned char *p;
	unsigned char f;

	p = (unsigned char *)&o;
	e = p + 9;
	do
		*p++ = 0;
	while (p < e);
	SeMenu_LoadMasterPtr(&m);
	f = 0x80;
	o.flags = f;
	f |= 0x08;
	o.flags = f;
	o.master = m;
	o.field = field;
	o.one = 1;
	o.value = *v;
	o.mask = mask;
	SeMenu_SetObjectFlags(id);
	SeMenu_FlushDisplayObj(&o);
	return 0;
}

extern unsigned char SeMenu_StepParamField(unsigned char *f);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern unsigned char SeMenu_BitShiftMask(int, int);
extern void SeMenu_SetupDisplayObject_Alt1(unsigned char, unsigned char, unsigned char *, unsigned int);
extern void SeMenu_StorePartParam(int, int);
extern void __cdecl SeTitle_DrawField(int, int);

unsigned char SeMenu_StepParamFieldAndSend(unsigned char t, unsigned char part, unsigned char id,
                                           unsigned char field, unsigned char *f)
{
	unsigned char obj;
	unsigned int m;

	if ((unsigned int)SeMenu_StepParamField(f) == 0)
		return 0;
	SeMenu_LoadObjEntries(&obj);
	m = SeMenu_BitShiftMask(f[6], f[7]);
	if (obj == 0)
		SeMenu_RegisterElement_Extended(id, field, &f[3], m);
	else
		SeMenu_SetupDisplayObject_Alt1(id, field, &f[3], m);
	SeMenu_StorePartParam(part, f[3]);
	SeTitle_DrawField(t, part);
	return 1;
}
