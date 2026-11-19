/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_1m289b.c (2026-11-19-15-p6-r42)
   sha256 aa1306fba2c1b8434e26f6ce64c515898d514f124af8b24e9578c35f350465a3 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
extern struct rec MidiCtl_NullRecord[];
extern unsigned char SysEx_Msg_35DC[];
void MidiPkt_EnqueueControl_335C(struct pr *p)
{
	unsigned char m[3] = { 0, 0, 0 };
	if (MidiPkt_CheckGateCondition((struct pkt *)p->rec) == -1) return;
	if (MidiCtl_NullRecord == p->rec) return;
	if ((p->rec->mask & p->pkt[3]) == 0) return;
	ArpQueue_Enqueue(SysEx_Msg_35DC, 6);
	ArpQueue_Enqueue((unsigned char *)p->rec, 6);
	m[0] = 0;
	if (p->rec->mask & p->pkt[2]) m[0] = 0x7f;
	m[1] = m[0] & 0x0f;
	m[0] = m[0] >> 4;
	ArpQueue_Enqueue(m, 3);
	ArpQueue_ComputeAndEnqueue();
	SeqOut_FlushTimedBuffer(ram_bc5c);
	ArpQueue_SwapBuffers();
}
