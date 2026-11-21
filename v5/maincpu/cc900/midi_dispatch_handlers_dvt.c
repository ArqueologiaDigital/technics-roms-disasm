/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
   v7 / v6 / v5 only (written by hand, 2026-11-20): v10 builds these from cc900/midipkt_routines_m0.c, but here the
   hand sources split them at another place (MidiPkt_DispatchViaTable_4D9A straddles midi_dispatch_handlers.s /
   midipkt_routines.s and stays hand assembly).  C from notes/cc900-c-nearmiss/c/<tree>/ (run 2026-11-19-43-p6-r48).
*/
/* cc900-module: MidiPkt_MatchParamInTable */

struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
struct rec { unsigned char h0, h1, h2, h3, h4, h5, h6; unsigned char id; unsigned char mask; unsigned char x9, x10;
             unsigned char shift; unsigned char g1, g2, x14, x15; unsigned char fn; unsigned char x17, x18, x19; };
struct pr { unsigned char *pkt; struct rec *rec; };
typedef void (*mhandler)(struct pr *);
extern struct rec *MidiPkt_MatchParamInTable(unsigned char *pkt, struct rec **list);
extern mhandler MidiCtl_Handlers[];
extern struct rec *MidiCtl_MatchList0[];
extern struct rec *MidiCtl_MatchList1[];
extern struct rec *MidiCtl_MatchList2[];

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
