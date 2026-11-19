/* Phase 6, lane_p6 helper M, round 3, module 277, form c: PanelInput_UpdatePedalRecord retry.
   As form a (struct record), with the input byte stored once after an xor of c (c ^= 0x0f under the test) and
   the change record's third byte written as nv ^ old. */
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
		c ^= 0x0f;
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
	q[2] = nv ^ old;
	PanelInput_QueueChange(q);
}
