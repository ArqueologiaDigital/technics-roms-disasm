/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_11m285b.c (2026-11-19-83-p6-r56)
   sha256 d061e02641d7fc0ceac4a09a9721fb351a4e00b270b68d1fa0b0c6e4a2a55c0d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: MidiPkt_SetXferTotal_AccompBlk=MidiPkt_SetXferTotal_AccompBlocks */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char __near ram_bd18;
extern unsigned char ram_1e8800;
extern long MidiPkt_GetUsedSize_AccompBlocks(void);
void MidiPkt_SetXferTotal_AccompBlk(struct xfer *x)
{
	long n;

	x->end = (x->start = &ram_1e8800) + 0x3c00;
	x->size = 0x3c00;
	if (ram_bd18 & 0x40) {
		n = MidiPkt_GetUsedSize_AccompBlocks();
		x->end = n + x->start;
		x->size = n;
	}
}
