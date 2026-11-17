/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_2a.c (2026-11-16-35-p6-r3)
   sha256 d3b51256cb6766ba5ee356b2f9ad6f2a91b76a80223fa8ae1385d53c17b0fdaa (tar-sha256); compiled at -O3 -Xr */
struct gate { unsigned char *p; unsigned char mask, val; };
struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
extern struct gate MidiCtl_GateRecords[], MidiCtl_SecondGateRecords[];
int MidiPkt_CheckGateCondition(struct pkt *k)
{
	struct gate *g;
	unsigned char *q;

	if (k->g1 != 0) {
		g = &MidiCtl_GateRecords[k->g1];
		q = g->p;
		if ((g->mask & *q) != g->val) return -1;
	}
	if (k->g2 != 0) {
		g = &MidiCtl_SecondGateRecords[k->g2];
		q = g->p;
		if ((g->mask & *q) != g->val) return -1;
	}
	return 0;
}
