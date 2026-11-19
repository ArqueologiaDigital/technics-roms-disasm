/* Phase 6, lane_p6 helper M, round 1, module 289, form a.
   MidiPkt_EnqueueControl_3354 (midi/midipkt_routines.s): one of the EnqueueControl senders that helper N writes
   in p6_N_1m289* (same declarations and the same idiom: the 3-byte message as an initialised local array whose
   template is mapped with cc900-data).  This one sends (pkt[2] & mask) >> (shift & 15) split into two nibbles. */
/* cc900-module: MidiPkt_CheckGateCondition */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
struct rec { unsigned char h[7]; unsigned char id; unsigned char mask; unsigned char x9, x10; unsigned char shift;
             unsigned char g1, g2, x14, x15; unsigned char fn; unsigned char x17, x18, x19; };
struct pr { unsigned char *pkt; struct rec *rec; };
struct mq;
typedef struct mq *mqp;

extern int MidiPkt_CheckGateCondition(struct pkt *k);
extern void ArpQueue_Enqueue(unsigned char *s, unsigned int n);
extern void ArpQueue_ComputeAndEnqueue(void);
extern void SeqOut_FlushTimedBuffer(mqp q);
extern void ArpQueue_SwapBuffers(void);

extern mqp __near ram_bc5c;
extern struct rec MidiCtl_NullRecord;
extern unsigned char SysEx_Msg_35DC[];
extern void MidiPkt_EnqueueControl_3354(struct pr *p);

/* cc900-data: MidiPkt_EnqueueControl_3354 1 = MidiPkt_MsgTemplate_334C */
void MidiPkt_EnqueueControl_3354(struct pr *p)
{
	unsigned char m[3] = { 0, 0, 0 };
	unsigned char *q;
	unsigned char v;

	if (MidiPkt_CheckGateCondition((struct pkt *)p->rec) == -1) return;
	if (&MidiCtl_NullRecord == p->rec) return;
	if ((p->pkt[3] & p->rec->mask) == 0) return;
	ArpQueue_Enqueue(SysEx_Msg_35DC, 6);
	ArpQueue_Enqueue((unsigned char *)p->rec, 6);
	v = p->pkt[2] & p->rec->mask;
	v >>= p->rec->shift & 15;
	q = m;
	*q = v;
	q[1] = *q & 0x0f;
	*q = *q >> 4;
	ArpQueue_Enqueue(q, 3);
	ArpQueue_ComputeAndEnqueue();
	SeqOut_FlushTimedBuffer(ram_bc5c);
	ArpQueue_SwapBuffers();
}
