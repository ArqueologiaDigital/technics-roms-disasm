/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midipkt_routines_dvt.c (2026-11-21-2-p6-r58)
   sha256 5211e2158b28b3e58ecaa030fca5018eec709f84526628eafe9c1d1db43c6a0e (tar-sha256); compiled at -O3 -XS -Xr
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
