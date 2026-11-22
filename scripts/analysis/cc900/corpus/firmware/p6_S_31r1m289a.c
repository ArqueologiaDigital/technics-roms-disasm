/* lane_p6 helper S, round 31r1: midi/midipkt_routines.s (module 289), form a.
   MidiPkt_SendCtlWordValueSysEx: twin of the built MidiPkt_EnqueueControl_3354 (cc900/midipkt_routines_m289.c)
   with a 16-bit value: the packet holds a value word at +2 and a mask word at +4.
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiPkt_CheckGateCondition */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
struct rec { unsigned char h[8]; unsigned char mask; unsigned char x9, x10; unsigned char shift; };
struct wpkt { unsigned char pad[2]; unsigned int val; unsigned int mask; };
struct wpr { struct wpkt *pkt; struct rec *rec; };
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
extern void MidiPkt_SendCtlWordValueSysEx(struct wpr *p);

/* cc900-data: MidiPkt_SendCtlWordValueSysEx 1 = MidiPkt_MsgTemplate_3350 */
void MidiPkt_SendCtlWordValueSysEx(struct wpr *p)
{
	unsigned char m[3] = { 0, 0, 0 };
	unsigned char *q;
	unsigned int v;

	if (MidiPkt_CheckGateCondition((struct pkt *)p->rec) == -1) return;
	if (&MidiCtl_NullRecord == p->rec) return;
	if (p->pkt->mask == 0) return;
	ArpQueue_Enqueue(SysEx_Msg_35DC, 6);
	ArpQueue_Enqueue((unsigned char *)p->rec, 6);
	v = p->pkt->val & p->pkt->mask;
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
