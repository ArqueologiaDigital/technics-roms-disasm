/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_20r1m285b.c (2026-11-21-2-p6-r58)
   sha256 77880df0adae25acd63a6413c40ba1d39d11d0dfdcc9038109684e8d5e9ea6d9 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: MidiPkt_SetXferBlk_AccompBank=MidiPkt_SetXferBlock_AccompBankTables */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char ram_1e8820;
extern unsigned char ram_1e8b00;
void MidiPkt_SetXferBlk_AccompBank(struct xfer *x)
{
	unsigned char *e;
	unsigned char *p = &ram_1e8820;
	register long n;

	x->start = p;
	n = &ram_1e8b00 - p;
	e = n + p;
	x->end = e;
	x->size = n;
}
