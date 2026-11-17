/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_1b.c (2026-11-16-31-p6-r1b)
   sha256 f545fd217b726e00a01edbda07882c98420980af6c0fec92898ed4803639eb58 (tar-sha256); compiled at -O3 -XS -Xr */
struct gate { unsigned char *p; unsigned char mask, val; };
struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
extern struct gate MidiCtl_GateRecords[], MidiCtl_SecondGateRecords[];
int MidiPkt_CheckGateCondition(struct pkt *k)
{
	struct gate *g;

	if (k->g1 != 0) {
		g = &MidiCtl_GateRecords[k->g1];
		if (g->val != (g->mask & *g->p)) return -1;
	}
	if (k->g2 != 0) {
		g = &MidiCtl_SecondGateRecords[k->g2];
		if (g->val == (g->mask & *g->p)) return 0;
		return -1;
	}
	return 0;
}
