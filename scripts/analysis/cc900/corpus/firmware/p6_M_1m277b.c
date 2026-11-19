/* Phase 6, lane_p6 helper M, round 1, module 277, form b (alternative to p6_M_1m277a.c).
   PanelInput_UpdatePedalRecord: the merge written with the operands of `|` and `&` swapped (V4.23 puts the right
   operand in the register), the previous input in a local, and the queue pointer taken before the test. */
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

	if (rec[0] == 0x1d && (c & 0x0f) == 0x0f)
		rec[1] = c ^ 0x0f;
	else
		rec[1] = c;
	if (ram_8ec4 >= 7)
		return;
	p = &rec[1];
	b = *p;
	if (b == 0 && rec[3] == 0)
		return;
	q = ram_8eb2;
	old = rec[3];
	prev = rec[2];
	nv = (old & (prev ^ b)) | (b & prev);
	rec[3] = nv;
	rec[2] = *p;
	if (nv == old)
		return;
	q[0] = rec[0];
	q[1] = nv;
	q[2] = old ^ nv;
	PanelInput_QueueChange(q);
}
