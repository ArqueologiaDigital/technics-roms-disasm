/* helper W, round 21r2, module 285 (midi/midi_dispatch_handlers.s), form a: MidiPkt_SetXferTotal_SeqData.  Run
   r59's best (p6_S_20r1m285c@O3Xr) matched the first 30 bytes; in the used-size branch the ROM forms the end as
   (n + 0x5800) into a new register (`lda xwa, (xhl+0x5800)`) and then adds the start reloaded from the record
   (`add xwa, (xiz)`), and recomputes the size as 0x5800 + n (`ld xwa, 0x5800; add xwa, xhl`, no reuse).  Here the
   end is written n first, the start last, and the size constant first.
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
		x->end = (unsigned char *)(n + 0x5800 + (long)x->start);
		x->size = 0x5800 + n;
	}
}
