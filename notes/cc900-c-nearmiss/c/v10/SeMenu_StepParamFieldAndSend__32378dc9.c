/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_N_2m129a.c (2026-11-19-19-p6-r43)
   sha256 32378dc9228e44ae21e6a84bdb4e9f965843a58b76181062ede977b1d86bf4b5 (tar-sha256); compiled at -O3 -Xr */
/* lane_p6 helper N, round 2, form a: module 129 (audio/semenu_routines.s).
   SeMenu_RegisterElement_Extended: builds a 9-byte display object on the stack (cleared, flags 0x88, master part,
   field id, 1, the current value, the step mask) and flushes it.  SeMenu_StepParamFieldAndSend: steps a parameter
   field and, when it changed, registers / updates its display object, stores the part parameter and redraws the
   title field.  SeWrtMem_SelectMemorySlotSound: program-change for memory slot n (bank 16 / 17, n % 20) and stores
   the result into the master part's panel record.
   Char parameters used across calls are homed in the frame by V4.23 -O3 itself (Part_ClearVoiceSlot).
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeMenu_BitShiftMask SeMenu_FlushDisplayObj SeMenu_LoadMasterPtr SeMenu_LoadObjEntries SeMenu_RegisterElement_Extended SeMenu_SetObjectFlags SeMenu_SetupDisplayObject_Alt1 SeMenu_StepParamField SeMenu_StorePartParam */

struct seobj { unsigned char flags, master, field, one, value, mask, x6, x7, x8; };
extern void SeMenu_LoadMasterPtr(unsigned char *m);
extern void SeMenu_SetObjectFlags(int);
extern void SeMenu_FlushDisplayObj(struct seobj *);
extern int SeMenu_RegisterElement_Extended(unsigned char id, unsigned char field, unsigned char *v, unsigned char mask);

int SeMenu_RegisterElement_Extended(unsigned char id, unsigned char field, unsigned char *v, unsigned char mask)
{
	unsigned char m;
	struct seobj o;
	unsigned char *p;

	for (p = (unsigned char *)&o; p < (unsigned char *)&o + 9; p++)
		*p = 0;
	SeMenu_LoadMasterPtr(&m);
	o.flags = 0x80;
	o.flags |= 0x08;
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

	if (SeMenu_StepParamField(f) == 0)
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

extern unsigned char __near PANEL_PART_RT1[];
extern unsigned char __near PANEL_PART_RT2[];
extern unsigned char __near PANEL_PART_LEFT[];
extern void SndParam_ApplyProgramChange(unsigned char *);
extern void __cdecl SeMenu_DisplayPartValue(int, int, int);

void SeWrtMem_SelectMemorySlotSound(unsigned char n)
{
	unsigned char s[6];
	unsigned char m;
	unsigned char q;
	unsigned char r;
	unsigned char *p;

	SeMenu_LoadMasterPtr(&m);
	q = n / 20;
	r = n % 20;
	if (q != 0)
		q = 17;
	else
		q = 16;
	s[0] = q;
	s[1] = r;
	s[2] = m;
	SndParam_ApplyProgramChange(s);
	q = s[3];
	r = s[4];
	if (m == 1)
		p = PANEL_PART_RT2;
	else if (m == 2)
		p = PANEL_PART_LEFT;
	else
		p = PANEL_PART_RT1;
	p[0] = q;
	p[1] = r;
	SeMenu_DisplayPartValue(m, q, r);
}
