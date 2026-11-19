/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_10m285a.c (2026-11-19-76-p6-r55)
   sha256 9fe9c6cce2bc761bf7d6492b4f75d5a22b56f14340a1edda3a6caaefbcfb0636 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char __near ram_bd18;
extern unsigned char ram_b0000[];
extern long MidiPkt_GetUsedSize_SeqEvents(void);
void MidiPkt_SetXferBlock_SeqEvents(struct xfer *x)
{
	long n;

	x->end = (x->start = ram_b0000) + 0x4d800;
	x->size = 0x4d800;
	if (ram_bd18 & 0x40) {
		n = MidiPkt_GetUsedSize_SeqEvents();
		x->end = x->start + n;
		x->size = n;
	}
}
