/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_1m289b.c (2026-11-19-15-p6-r42)
   sha256 aa1306fba2c1b8434e26f6ce64c515898d514f124af8b24e9578c35f350465a3 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
struct rec { unsigned char h[7]; unsigned char id; unsigned char mask; unsigned char x9, x10; unsigned char shift;
             unsigned char g1, g2, x14, x15; unsigned char fn; unsigned char x17, x18, x19; };
struct pr { unsigned char *pkt; struct rec *rec; };
typedef void (*mhandler)(struct pr *);
extern struct rec *MidiPkt_MatchParamInTable(unsigned char *pkt, struct rec **list);
extern mhandler MidiCtl_Handlers[];
extern struct rec *MidiCtl_MatchList3[];
void MidiPkt_DispatchViaTable_4D9A(unsigned char *pkt)
{
	struct pr s;
	s.rec = MidiPkt_MatchParamInTable(pkt, MidiCtl_MatchList3);
	s.pkt = pkt;
	MidiCtl_Handlers[s.rec->fn](&s);
}
