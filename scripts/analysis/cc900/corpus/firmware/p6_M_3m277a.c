/* Phase 6, lane_p6 helper M, round 3, module 277, form a: PanelInput_UpdatePedalRecord retry.
   Run r41: 1m277b@O3Xr +6.  V4.23 merged &rec[1] of the first store with p = &rec[1] into one spilled temporary;
   the ROM computes it twice (XHL for the store, then p in the frame at +8, old at +12).  This form: the record as a
   struct (member stores first, p = &r->in later), the merge in the ROM's order (the xor/and part, the operand of `|`
   on the right, first). */
/* cc900-module: PanelInput_QueueChange */   /* scripts/analysis/cc900/module_calls.py v10 */

struct ped { unsigned char code, in, prev, state; };
extern unsigned char __near ram_8ec4;
extern unsigned char __near ram_8eb2[];
extern void PanelInput_QueueChange(unsigned char *);
extern void PanelInput_UpdatePedalRecord(struct ped *r, unsigned char c);

void PanelInput_UpdatePedalRecord(struct ped *r, unsigned char c)
{
	unsigned char *q;
	unsigned char *p;
	unsigned char old;
	unsigned char b;
	unsigned char prev;
	unsigned char nv;

	if (r->code == 0x1d && (c & 0x0f) == 0x0f)
		r->in = c ^ 0x0f;
	else
		r->in = c;
	if (ram_8ec4 >= 7)
		return;
	p = &r->in;
	b = *p;
	if (b == 0 && r->state == 0)
		return;
	q = ram_8eb2;
	old = r->state;
	prev = r->prev;
	nv = (prev & b) | ((prev ^ b) & old);
	r->state = nv;
	r->prev = *p;
	if (nv == old)
		return;
	q[0] = r->code;
	q[1] = nv;
	q[2] = old ^ nv;
	PanelInput_QueueChange(q);
}
