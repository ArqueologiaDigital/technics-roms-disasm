/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_20r1m285a.c (2026-11-21-2-p6-r58)
   sha256 6c84497e3c9dd27dd906909305695d9fc28ad7c6ab63f559bc1eda4918461b57 (tar-sha256); compiled at -O3 -XS -Xr
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
		x->end = (unsigned char *)((long)x->start + 0x5800 + n);
		x->size = 0x5800 + n;
	}
}
