/* Phase 6, lane_p6 helper M, round 3, module 289, form a: MidiPkt_EnqueueControl_3354 retry (run r41: +28 @Xr; the
   O3Xr listing was the ROM's code except two spots).
   1. The record: V4.23 pads the 7-byte member array h[7] to 8, so `id` landed at +8 and `mask` at +9; the ROM reads
      the mask at +8 and the shift at +11: the record's header is h[8] here (helper N's struct rec has the same
      h[7] layout).
   2. `v >>= shift` with no `& 15`: V4.23 emits `and a,15; jr z` itself before `srl A,r` (the C's own & 15 gave a
      second `and`). */
/* cc900-module: MidiPkt_CheckGateCondition */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
struct rec { unsigned char h[8]; unsigned char mask; unsigned char x9, x10; unsigned char shift; };
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
	v >>= p->rec->shift;
	q = m;
	*q = v;
	q[1] = *q & 0x0f;
	*q = *q >> 4;
	ArpQueue_Enqueue(q, 3);
	ArpQueue_ComputeAndEnqueue();
	SeqOut_FlushTimedBuffer(ram_bc5c);
	ArpQueue_SwapBuffers();
}
