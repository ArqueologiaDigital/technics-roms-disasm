/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_11m285a.c (2026-11-19-83-p6-r56)
   sha256 8df77b398fa2ebf05c3e8cba6e13d5cec82fde9a09201178172d285966e1dcd0 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char __near ram_bd18;
extern unsigned char __near SEQ_SONG_RECORD;
extern long MidiPkt_GetUsedSize_SeqEvents(void);
void MidiPkt_SetXferTotal_SeqData(struct xfer *x)
{
	long n;

	x->end = (x->start = &SEQ_SONG_RECORD) + 0x53000;
	x->size = 0x53000;
	if (ram_bd18 & 0x40) {
		n = MidiPkt_GetUsedSize_SeqEvents();
		x->end = (unsigned char *)(n + 0x5800 + (long)x->start);
		x->size = 0x5800 + n;
	}
}
