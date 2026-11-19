/* lane_p6 helper N, round 5, form a: module 285 (midi/midi_dispatch_handlers.s), new function of the built
   SetXferBlock family (cc900/midi_dispatch_handlers.c: SongSlots `x->end = (x->start = ...) + N`).
   MidiPkt_SetXferBlock_StyleImagePool: the style image pool at 0x95bc0, 0x15440 bytes; when bit 6 of 0xbd18 is
   set, only its used part: GetUsedSize_StyleImage minus the space before the pool ((0x94860 - pattern buffer A)
   + (0x95bc0 - 0x94860)).
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiPkt_GetUsedSize_StyleImage */

struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char ram_95bc0;
extern unsigned char ram_94860;
extern unsigned char RHYTHM_PATTERN_BUF_A[];
extern unsigned char __near ram_bd18;
extern long MidiPkt_GetUsedSize_StyleImage(void);

void MidiPkt_SetXferBlock_StyleImagePool(struct xfer *x)
{
	long n;
	long d;

	x->end = (x->start = &ram_95bc0) + 0x15440;
	x->size = 0x15440;
	if (ram_bd18 & 0x40) {
		n = MidiPkt_GetUsedSize_StyleImage();
		d = (&ram_94860 - RHYTHM_PATTERN_BUF_A) + (&ram_95bc0 - &ram_94860);
		x->end = x->start + n - d;
		x->size = n - d;
	}
}
