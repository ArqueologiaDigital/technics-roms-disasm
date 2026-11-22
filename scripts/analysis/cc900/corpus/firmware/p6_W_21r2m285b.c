/* helper W, round 21r2, module 285, form b: MidiPkt_SetXferTotal_SeqData as form a, the end as an integer added to
   the start pointer, `(n + 0x5800) + x->start` (form a: all in long arithmetic).
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiPkt_GetUsedSize_SeqEvents */

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
		x->end = (n + 0x5800) + x->start;
		x->size = 0x5800 + n;
	}
}
