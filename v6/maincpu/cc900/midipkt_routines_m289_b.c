/* Functions of midi/midipkt_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiPkt_CheckGateCondition MidiPkt_MatchParamInTable */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
struct rec { unsigned char h0, h1, h2, h3, h4, h5, h6; unsigned char id; unsigned char mask; unsigned char x9, x10;
             unsigned char shift; unsigned char g1, g2, x14, x15; unsigned char fn; unsigned char x17, x18, x19; };
struct pr { unsigned char *pkt; struct rec *rec; };
typedef void (*mhandler)(struct pr *);
struct mq;
typedef struct mq *mqp;
extern struct rec *MidiPkt_MatchParamInTable(unsigned char *pkt, struct rec **list);
extern void ArpQueue_Enqueue(unsigned char *s, unsigned int n);
extern void SeqOut_FlushTimedBuffer(mqp q);
extern void ArpQueue_SwapBuffers(void);
extern mqp __near ram_bb9c;
extern mhandler MidiCtl_Handlers[];
extern unsigned char SysEx_GmSystemOn[];
extern unsigned char SysEx_GmSystemOff[];
extern struct rec *MidiCtl_MatchList6[];
extern void MidiPkt_DispatchSpecialType(unsigned char *pkt);
extern struct rec *MidiCtl_MatchList7[];
extern void __cdecl MidiPkt_DispatchViaTable_4DCE(unsigned char *pkt);
extern int MidiPkt_CheckGateCondition(struct pkt *k);
extern void ArpQueue_ComputeAndEnqueue(void);
extern struct rec MidiCtl_NullRecord;
extern unsigned char SysEx_Msg_35DC[];
extern void MidiPkt_EnqueueControl_335C(struct pr *p);
extern unsigned char __near PANEL_STYLE[];
extern void MidiPkt_EnqueueControl_3364(struct pr *p);

void MidiPkt_DispatchSpecialType(unsigned char *pkt)
{
	struct pr s;
	unsigned char t = pkt[1];
	if (t == 0x11) {
		ArpQueue_Enqueue(SysEx_GmSystemOn, 6);
		SeqOut_FlushTimedBuffer(ram_bb9c);
		ArpQueue_SwapBuffers();
	} else if (t == 0x10) {
		ArpQueue_Enqueue(SysEx_GmSystemOff, 6);
		SeqOut_FlushTimedBuffer(ram_bb9c);
		ArpQueue_SwapBuffers();
	} else {
		s.rec = MidiPkt_MatchParamInTable(pkt, MidiCtl_MatchList6);
		s.pkt = pkt;
		MidiCtl_Handlers[s.rec->fn](&s);
	}
}

void __cdecl MidiPkt_DispatchViaTable_4DCE(unsigned char *pkt)
{
	struct pr s;
	s.rec = MidiPkt_MatchParamInTable(pkt, MidiCtl_MatchList7);
	s.pkt = pkt;
	MidiCtl_Handlers[s.rec->fn](&s);
}

/* cc900-data: MidiPkt_EnqueueControl_335C 1 = MidiPkt_MsgTemplate_3354 */
void MidiPkt_EnqueueControl_335C(struct pr *p)
{
	unsigned char m[3] = { 0, 0, 0 };
	unsigned char *q;
	if (MidiPkt_CheckGateCondition((struct pkt *)p->rec) == -1) return;
	if (&MidiCtl_NullRecord == p->rec) return;
	if ((p->pkt[3] & p->rec->mask) == 0) return;
	ArpQueue_Enqueue(SysEx_Msg_35DC, 6);
	ArpQueue_Enqueue((unsigned char *)p->rec, 6);
	q = m;
	*q = 0;
	if (p->pkt[2] & p->rec->mask) *q = 0x7f;
	q[1] = *q & 0x0f;
	*q = *q >> 4;
	ArpQueue_Enqueue(q, 3);
	ArpQueue_ComputeAndEnqueue();
	SeqOut_FlushTimedBuffer(ram_bb9c);
	ArpQueue_SwapBuffers();
}

/* cc900-data: MidiPkt_EnqueueControl_3364 1 = MidiPkt_MsgTemplate_3364 */
void MidiPkt_EnqueueControl_3364(struct pr *p)
{
	unsigned char m[3] = { 0, 0, 0 };
	unsigned char c;
	if (MidiPkt_CheckGateCondition((struct pkt *)p->rec) == -1) return;
	if ((p->pkt[3] & p->rec->mask) == 0) return;
	ArpQueue_Enqueue(SysEx_Msg_35DC, 6);
	ArpQueue_Enqueue((unsigned char *)p->rec, 6);
	if ((p->pkt[2] & p->rec->mask) == 1) {
		c = PANEL_STYLE[7] & 0x30;
		c >>= p->rec->shift;
		m[0] = c + 1;
	}
	m[1] = m[0] & 0x0f;
	m[0] = m[0] >> 4;
	ArpQueue_Enqueue(m, 3);
	ArpQueue_ComputeAndEnqueue();
	SeqOut_FlushTimedBuffer(ram_bb9c);
	ArpQueue_SwapBuffers();
}
