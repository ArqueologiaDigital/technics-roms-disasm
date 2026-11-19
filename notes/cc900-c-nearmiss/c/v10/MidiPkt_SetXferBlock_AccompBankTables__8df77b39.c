/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_11m285a.c (2026-11-19-83-p6-r56)
   sha256 8df77b398fa2ebf05c3e8cba6e13d5cec82fde9a09201178172d285966e1dcd0 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: MidiPkt_SetXferBlk_AccompBank=MidiPkt_SetXferBlock_AccompBankTables */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char ram_1e8820;
extern unsigned char ram_1e8b00;
void MidiPkt_SetXferBlk_AccompBank(struct xfer *x)
{
	unsigned char *e;
	unsigned char *p = &ram_1e8820;
	long n;

	x->start = p;
	n = &ram_1e8b00 - p;
	e = n + p;
	x->end = e;
	x->size = n;
}
