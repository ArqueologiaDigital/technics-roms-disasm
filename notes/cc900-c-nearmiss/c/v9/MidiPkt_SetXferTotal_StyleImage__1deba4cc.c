/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/midi_dispatch_handlers_m285.c (2026-11-19-92-p6-r57)
   sha256 1deba4cc95e725795a03b7b7e8781af2ba6e2fb4743995c4f5377e41eba28d65 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr
   cc900-name: MidiPkt_SetXferTotal_StyleImg=MidiPkt_SetXferTotal_StyleImage */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char __near ram_bd18;
extern unsigned char RHYTHM_PATTERN_BUF_A[];
extern long MidiPkt_GetUsedSize_StyleImage(void);
void MidiPkt_SetXferTotal_StyleImg(struct xfer *x)
{
	long n;

	x->end = (x->start = RHYTHM_PATTERN_BUF_A) + 0x16800;
	x->size = 0x16800;
	if (ram_bd18 & 0x40) {
		n = MidiPkt_GetUsedSize_StyleImage();
		x->end = (unsigned char *)((long)x->start + n);
		x->size = n;
	}
}
