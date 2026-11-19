/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_3m289a.c (2026-11-19-22-p6-r45)
   sha256 2c0a765b16161a4f0b7f199e50d2cfbb7a20d4d7b9fc3501256cb541d4d218e3 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
struct rec { unsigned char h0, h1, h2, h3, h4, h5, h6; unsigned char id; unsigned char mask; unsigned char x9, x10;
             unsigned char shift; unsigned char g1, g2, x14, x15; unsigned char fn; unsigned char x17, x18, x19; };
struct pr { unsigned char *pkt; struct rec *rec; };
typedef void (*mhandler)(struct pr *);
extern struct rec *MidiPkt_MatchParamInTable(unsigned char *pkt, struct rec **list);
extern mhandler MidiCtl_Handlers[];
extern struct rec *MidiCtl_MatchList5[];
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
