/* helper Z, round 22r1, module 285 (midi/midi_dispatch_handlers.s), form a: MidiPkt_SetXferTotal_SeqData.  Run
   r64's best (p6_W_21r2m285b@Xr) differed at +31: the ROM forms the end as `lda xwa, (xhl+0x5800); add xwa,
   (xiz)` and the size separately as `ld xwa, 0x5800; add xwa, xhl`.  lda with a displacement is what V4.23
   emits for POINTER + constant (built examples: DataBuf_CopyBulkBitfields_944, Demo_GetPresetBaseForPart), and the
   two `n + 0x5800` not being shared at -O3 says they have different types.  Here the end is pointer arithmetic on
   the size cast to a pointer, then the start added as a long.  Form b: the size local itself a pointer.
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
		x->end = (unsigned char *)n + 0x5800 + (long)x->start;
		x->size = 0x5800 + n;
	}
}
