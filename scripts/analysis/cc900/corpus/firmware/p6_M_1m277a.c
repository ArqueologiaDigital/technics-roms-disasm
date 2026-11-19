/* Phase 6, lane_p6 helper M, round 1, module 277, form a.
   PanelInput_UpdatePedalRecord (audio/audio_control_engine.s): store the new input byte c in rec[1] (code 0x1d with
   low nibble 0xf stores it with the nibble cleared), then, while the change queue (count ram_8ec4) has room, merge it
   into the latched state rec[3] (rec[2] = the previous input) and queue a 3-byte change record {code, state, toggled}
   from the scratch cell ram_8eb2.  Locals: q, p, old in the frame in that order (+4, +8, +12). */
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
	unsigned char nv;

	if (rec[0] == 0x1d && (c & 0x0f) == 0x0f)
		rec[1] = c ^ 0x0f;
	else
		rec[1] = c;
	if (ram_8ec4 < 7) {
		p = &rec[1];
		b = *p;
		if (b != 0 || rec[3] != 0) {
			q = ram_8eb2;
			old = rec[3];
			nv = (rec[2] & b) | ((rec[2] ^ b) & old);
			rec[3] = nv;
			rec[2] = *p;
			if (nv != old) {
				q[0] = rec[0];
				q[1] = nv;
				q[2] = old ^ nv;
				PanelInput_QueueChange(q);
			}
		}
	}
}
