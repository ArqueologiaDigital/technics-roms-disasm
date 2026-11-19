/* lane_p6 helper N, round 1, form a: module 289 (midi/midipkt_routines.s).
   The MIDI control-record dispatchers (MidiPkt_DispatchViaTable_*, MidiPkt_DispatchSpecialType) and the
   EnqueueControl senders.  Form a: the record as a struct, the null record compared by `&`, the 3-byte message
   as an initialised local array (its template mapped with cc900-data), `pkt & rec` with the record on the right.
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiPkt_CheckGateCondition MidiPkt_MatchParamInTable */

struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
struct rec { unsigned char h[7]; unsigned char id; unsigned char mask; unsigned char x9, x10; unsigned char shift;
             unsigned char g1, g2, x14, x15; unsigned char fn; unsigned char x17, x18, x19; };
struct pr { unsigned char *pkt; struct rec *rec; };
typedef void (*mhandler)(struct pr *);
struct mq;
typedef struct mq *mqp;

extern int MidiPkt_CheckGateCondition(struct pkt *k);
extern struct rec *MidiPkt_MatchParamInTable(unsigned char *pkt, struct rec **list);
extern void ArpQueue_Enqueue(unsigned char *s, unsigned int n);
extern void ArpQueue_ComputeAndEnqueue(void);
extern void SeqOut_FlushTimedBuffer(mqp q);
extern void ArpQueue_SwapBuffers(void);

extern mqp __near ram_bc5c;
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near PANEL_PMEM_SETTINGS[];
extern mhandler MidiCtl_Handlers[];
extern struct rec MidiCtl_NullRecord;
extern unsigned char MidiCtl_Rec_07[];
extern unsigned char SysEx_Msg_35DC[];
extern unsigned char SysEx_GmSystemOn[];
extern unsigned char SysEx_GmSystemOff[];
extern struct rec *MidiCtl_MatchList0[];
extern struct rec *MidiCtl_MatchList1[];
extern struct rec *MidiCtl_MatchList2[];
extern struct rec *MidiCtl_MatchList3[];
extern struct rec *MidiCtl_MatchList4[];
extern struct rec *MidiCtl_MatchList5[];
extern struct rec *MidiCtl_MatchList6[];
extern struct rec *MidiCtl_MatchList7[];

void MidiPkt_DispatchViaTable_4D6A(unsigned char *pkt)
{
	struct pr s;
	s.rec = MidiPkt_MatchParamInTable(pkt, MidiCtl_MatchList0);
	s.pkt = pkt;
	MidiCtl_Handlers[s.rec->fn](&s);
}

void MidiPkt_DispatchViaTable_4D82(unsigned char *pkt)
{
	struct pr s;
	s.rec = MidiPkt_MatchParamInTable(pkt, MidiCtl_MatchList1);
	s.pkt = pkt;
	MidiCtl_Handlers[s.rec->fn](&s);
}

void MidiPkt_DispatchViaTable_4D8E(unsigned char *pkt)
{
	struct pr s;
	s.rec = MidiPkt_MatchParamInTable(pkt, MidiCtl_MatchList2);
	s.pkt = pkt;
	MidiCtl_Handlers[s.rec->fn](&s);
}

void MidiPkt_DispatchViaTable_4D9A(unsigned char *pkt)
{
	struct pr s;
	s.rec = MidiPkt_MatchParamInTable(pkt, MidiCtl_MatchList3);
	s.pkt = pkt;
	MidiCtl_Handlers[s.rec->fn](&s);
}

void MidiPkt_DispatchViaTable_4DA6(unsigned char *pkt)
{
	struct pr s;
	s.rec = MidiPkt_MatchParamInTable(pkt, MidiCtl_MatchList4);
	s.pkt = pkt;
	MidiCtl_Handlers[s.rec->fn](&s);
}

void MidiPkt_DispatchViaTable_4DAE(unsigned char *pkt)
{
	struct pr s;
	s.rec = MidiPkt_MatchParamInTable(pkt, MidiCtl_MatchList5);
	s.pkt = pkt;
	MidiCtl_Handlers[s.rec->fn](&s);
	if (pkt[1] == 0x0b) {
		if ((pkt[3] &= ~s.rec->mask) != 0) {
			s.rec = MidiPkt_MatchParamInTable(pkt, MidiCtl_MatchList5);
			s.pkt = pkt;
			MidiCtl_Handlers[s.rec->fn](&s);
		}
	}
}

void MidiPkt_DispatchSpecialType(unsigned char *pkt)
{
	struct pr s;
	unsigned char t = pkt[1];
	if (t == 0x11) {
		ArpQueue_Enqueue(SysEx_GmSystemOn, 6);
		SeqOut_FlushTimedBuffer(ram_bc5c);
		ArpQueue_SwapBuffers();
	} else if (t == 0x10) {
		ArpQueue_Enqueue(SysEx_GmSystemOff, 6);
		SeqOut_FlushTimedBuffer(ram_bc5c);
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
	SeqOut_FlushTimedBuffer(ram_bc5c);
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
		c >>= p->rec->shift & 0x0f;
		m[0] = c + 1;
	}
	m[1] = m[0] & 0x0f;
	m[0] = m[0] >> 4;
	ArpQueue_Enqueue(m, 3);
	ArpQueue_ComputeAndEnqueue();
	SeqOut_FlushTimedBuffer(ram_bc5c);
	ArpQueue_SwapBuffers();
}

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
		c >>= p->rec->shift & 0x0f;
		m[0] = c + 1;
	} else {
		ArpQueue_Enqueue((unsigned char *)p->rec, 6);
		c = p->pkt[2] & p->rec->mask;
		c >>= p->rec->shift & 0x0f;
		m[0] = c;
	}
	m[1] = m[0] & 0x0f;
	m[0] = m[0] >> 4;
	ArpQueue_Enqueue(m, 3);
	ArpQueue_ComputeAndEnqueue();
	SeqOut_FlushTimedBuffer(ram_bc5c);
	ArpQueue_SwapBuffers();
}
