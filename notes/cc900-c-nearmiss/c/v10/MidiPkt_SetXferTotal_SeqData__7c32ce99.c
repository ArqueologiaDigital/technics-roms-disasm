/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_22r1m285b.c (2026-11-21-21-p6-r66)
   sha256 7c32ce99986e5b249fdfe0488c07248f4ee8cc9169fd18a9ea140142ff1e3c56 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char __near ram_bd18;
extern unsigned char __near SEQ_SONG_RECORD;
extern unsigned char *MidiPkt_GetUsedSize_SeqEvents(void);
void MidiPkt_SetXferTotal_SeqData(struct xfer *x)
{
	unsigned char *n;

	x->end = (x->start = &SEQ_SONG_RECORD) + 0x53000;
	x->size = 0x53000;
	if (ram_bd18 & 0x40) {
		n = MidiPkt_GetUsedSize_SeqEvents();
		x->end = n + 0x5800 + (long)x->start;
		x->size = 0x5800 + (long)n;
	}
}
