/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/midi_dispatch_handlers_m285.c (2026-11-19-92-p6-r57)
   sha256 1deba4cc95e725795a03b7b7e8781af2ba6e2fb4743995c4f5377e41eba28d65 (tar-sha256); compiled at -O3 -XS -Xr
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
		x->end = (unsigned char *)((long)x->start + n);
		x->size = n;
	}
}
