/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midipkt_routines_m0.c (2026-11-19-43-p6-r48)
   sha256 ab4fa4d8216a8c593edbc95fe2199cc3b574c51f714bafa8c3a62e70ea4bc612 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
struct rec { unsigned char h0, h1, h2, h3, h4, h5, h6; unsigned char id; unsigned char mask; unsigned char x9, x10;
             unsigned char shift; unsigned char g1, g2, x14, x15; unsigned char fn; unsigned char x17, x18, x19; };
struct pr { unsigned char *pkt; struct rec *rec; };
typedef void (*mhandler)(struct pr *);
extern struct rec *MidiPkt_MatchParamInTable(unsigned char *pkt, struct rec **list);
extern mhandler MidiCtl_Handlers[];
extern struct rec *MidiCtl_MatchList0[];
void MidiPkt_DispatchViaTable_4D6A(unsigned char *pkt)
{
	struct pr s;
	s.rec = MidiPkt_MatchParamInTable(pkt, MidiCtl_MatchList0);
	s.pkt = pkt;
	MidiCtl_Handlers[s.rec->fn](&s);
}
