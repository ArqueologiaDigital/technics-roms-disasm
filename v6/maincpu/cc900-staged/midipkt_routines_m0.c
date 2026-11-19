/* HELD BACK (lane_p6, 2026-11-19): see v7/maincpu/cc900-staged/midipkt_routines_m0.c (the same file boundary cuts
   MidiPkt_DispatchViaTable_4D9A here).
   Functions of midi/midipkt_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
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
extern struct rec *MidiPkt_MatchParamInTable(unsigned char *pkt, struct rec **list);
extern mhandler MidiCtl_Handlers[];
extern struct rec *MidiCtl_MatchList0[];
extern void MidiPkt_DispatchViaTable_4D6A(unsigned char *pkt);
extern struct rec *MidiCtl_MatchList1[];
extern void MidiPkt_DispatchViaTable_4D82(unsigned char *pkt);
extern struct rec *MidiCtl_MatchList2[];
extern void MidiPkt_DispatchViaTable_4D8E(unsigned char *pkt);
extern struct rec *MidiCtl_MatchList3[];
extern void MidiPkt_DispatchViaTable_4D9A(unsigned char *pkt);
extern struct rec *MidiCtl_MatchList4[];
extern void MidiPkt_DispatchViaTable_4DA6(unsigned char *pkt);
extern struct rec *MidiCtl_MatchList5[];
extern void MidiPkt_DispatchViaTable_4DAE(unsigned char *pkt);

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
