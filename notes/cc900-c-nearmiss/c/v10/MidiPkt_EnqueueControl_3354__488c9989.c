/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_1m289a.c (2026-11-19-13-p6-r41)
   sha256 488c99892e9cffec6f70740e84edd61a013c15f6eb31589875f978b3bcdd5108 (tar-sha256); compiled at -O3 -Xr */
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
