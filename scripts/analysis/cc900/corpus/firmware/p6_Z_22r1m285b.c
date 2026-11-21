/* helper Z, round 22r1, module 285 (midi/midi_dispatch_handlers.s), form b: MidiPkt_SetXferTotal_SeqData, as form
   a but the used size held in a pointer local (the callee declared returning a pointer), the end as that pointer
   plus 0x5800 plus the start as a long, the size as 0x5800 plus the pointer as a long.
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiPkt_GetUsedSize_SeqEvents */

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
