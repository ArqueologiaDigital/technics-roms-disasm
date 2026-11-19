/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_1m289b.c (2026-11-19-15-p6-r42)
   sha256 aa1306fba2c1b8434e26f6ce64c515898d514f124af8b24e9578c35f350465a3 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
struct rec { unsigned char h[7]; unsigned char id; unsigned char mask; unsigned char x9, x10; unsigned char shift;
             unsigned char g1, g2, x14, x15; unsigned char fn; unsigned char x17, x18, x19; };
struct pr { unsigned char *pkt; struct rec *rec; };
typedef void (*mhandler)(struct pr *);
struct mq;
typedef struct mq *mqp;
extern struct rec *MidiPkt_MatchParamInTable(unsigned char *pkt, struct rec **list);
extern void ArpQueue_Enqueue(unsigned char *s, unsigned int n);
extern void SeqOut_FlushTimedBuffer(mqp q);
extern void ArpQueue_SwapBuffers(void);
extern mqp __near ram_bc5c;
extern mhandler MidiCtl_Handlers[];
extern unsigned char SysEx_GmSystemOn[];
extern unsigned char SysEx_GmSystemOff[];
extern struct rec *MidiCtl_MatchList6[];
void MidiPkt_DispatchSpecialType(unsigned char *pkt)
{
	struct pr s;
	switch (pkt[1]) {
	case 0x10:
		ArpQueue_Enqueue(SysEx_GmSystemOff, 6);
		SeqOut_FlushTimedBuffer(ram_bc5c);
		ArpQueue_SwapBuffers();
		break;
	case 0x11:
		ArpQueue_Enqueue(SysEx_GmSystemOn, 6);
		SeqOut_FlushTimedBuffer(ram_bc5c);
		ArpQueue_SwapBuffers();
		break;
	default:
		s.rec = MidiPkt_MatchParamInTable(pkt, MidiCtl_MatchList6);
		s.pkt = pkt;
		MidiCtl_Handlers[s.rec->fn](&s);
		break;
	}
}
