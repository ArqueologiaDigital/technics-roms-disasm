/* Phase 6, lane_p6 helper M, round 3, module 277, form b: PanelInput_UpdatePedalRecord retry.
   As form a, but the first store goes through an explicit pointer local t (the ROM's XHL, dead after the store)
   and p is recomputed from rec later; byte-array record as in round 1. */
/* cc900-module: PanelInput_QueueChange */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_8ec4;
extern unsigned char __near ram_8eb2[];
extern void PanelInput_QueueChange(unsigned char *);
extern void PanelInput_UpdatePedalRecord(unsigned char *rec, unsigned char c);

void PanelInput_UpdatePedalRecord(unsigned char *rec, unsigned char c)
{
	unsigned char *q;
	unsigned char *p;
	unsigned char old;
	unsigned char b;
	unsigned char prev;
	unsigned char nv;
	unsigned char *t;

	t = &rec[1];
	if (rec[0] == 0x1d && (c & 0x0f) == 0x0f)
		*t = c ^ 0x0f;
	else
		*t = c;
	if (ram_8ec4 >= 7)
		return;
	p = &rec[1];
	b = *p;
	if (b == 0 && rec[3] == 0)
		return;
	q = ram_8eb2;
	old = rec[3];
	prev = rec[2];
	nv = (prev & b) | ((prev ^ b) & old);
	rec[3] = nv;
	rec[2] = *p;
	if (nv == old)
		return;
	q[0] = rec[0];
	q[1] = nv;
	q[2] = old ^ nv;
	PanelInput_QueueChange(q);
}
