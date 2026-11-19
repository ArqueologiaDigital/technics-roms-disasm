/* lane_p6 helper N, round 3, form b: module 289 (midi/midipkt_routines.s), MidiPkt_EnqueueControl_3368 only.
   The ROM shares the store of m[0] at the join of the two branches (the pedal branch ends `inc c; jr` to it) and
   then reloads m[0] through a pointer.  Form c: the store in the else branch, the pedal branch jumping to it
   with a goto (a hand-made cross jump).
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiPkt_CheckGateCondition */

struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
struct rec { unsigned char h0, h1, h2, h3, h4, h5, h6; unsigned char id; unsigned char mask; unsigned char x9, x10;
             unsigned char shift; unsigned char g1, g2, x14, x15; unsigned char fn; unsigned char x17, x18, x19; };
struct pr { unsigned char *pkt; struct rec *rec; };
struct mq;
typedef struct mq *mqp;

extern int MidiPkt_CheckGateCondition(struct pkt *k);
extern void ArpQueue_Enqueue(unsigned char *s, unsigned int n);
extern void ArpQueue_ComputeAndEnqueue(void);
extern void SeqOut_FlushTimedBuffer(mqp q);
extern void ArpQueue_SwapBuffers(void);
extern mqp __near ram_bc5c;
extern unsigned char __near PANEL_PMEM_SETTINGS[];
extern unsigned char MidiCtl_Rec_07[];
extern unsigned char SysEx_Msg_35DC[];

/* cc900-data: MidiPkt_EnqueueControl_3368 1 = MidiPkt_MsgTemplate_3368 */
void MidiPkt_EnqueueControl_3368(struct pr *p)
{
	unsigned char m[3] = { 0, 0, 0 };
	unsigned char c;
	if (MidiPkt_CheckGateCondition((struct pkt *)p->rec) == -1) return;
	if ((p->pkt[3] & p->rec->mask) == 0) return;
	ArpQueue_Enqueue(SysEx_Msg_35DC, 6);
	if ((PANEL_PMEM_SETTINGS[3] & 1) == 1) {
		ArpQueue_Enqueue(MidiCtl_Rec_07, 6);
		c = p->pkt[2] & p->rec->mask;
		c >>= p->rec->shift;
		c++;
		goto store;
	} else {
		ArpQueue_Enqueue((unsigned char *)p->rec, 6);
		c = p->pkt[2] & p->rec->mask;
		c >>= p->rec->shift;
store:
		m[0] = c;
	}
	m[1] = m[0] & 0x0f;
	m[0] = m[0] >> 4;
	ArpQueue_Enqueue(m, 3);
	ArpQueue_ComputeAndEnqueue();
	SeqOut_FlushTimedBuffer(ram_bc5c);
	ArpQueue_SwapBuffers();
}
