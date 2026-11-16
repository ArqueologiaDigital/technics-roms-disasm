/* Functions of midi/midipkt_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct gate { unsigned char *p; unsigned char mask, val; };
struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
extern struct gate MidiCtl_GateRecords[], MidiCtl_SecondGateRecords[];

int MidiPkt_CheckGateCondition(struct pkt *k)
{
	if (k->g1 != 0) {
		if ((*MidiCtl_GateRecords[k->g1].p & MidiCtl_GateRecords[k->g1].mask) != MidiCtl_GateRecords[k->g1].val)
			return -1;
	}
	if (k->g2 != 0) {
		if ((*MidiCtl_SecondGateRecords[k->g2].p & MidiCtl_SecondGateRecords[k->g2].mask)
		    != MidiCtl_SecondGateRecords[k->g2].val)
			return -1;
	}
	return 0;
}
