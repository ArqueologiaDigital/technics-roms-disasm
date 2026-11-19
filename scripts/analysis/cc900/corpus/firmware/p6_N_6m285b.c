/* lane_p6 helper N, round 6, form b: module 285 (midi/midi_dispatch_handlers.s), retry of p6_N_5m285a.
   MidiPkt_SetXferBlock_StyleImagePool, form b against a: no local for the difference (written in both
   statements, left to CSE), n kept.
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

	x->end = (x->start = &ram_95bc0) + 0x15440;
	x->size = 0x15440;
	if (ram_bd18 & 0x40) {
		n = MidiPkt_GetUsedSize_StyleImage();
		x->end = x->start + n - ((&ram_94860 - RHYTHM_PATTERN_BUF_A) + (&ram_95bc0 - &ram_94860));
		x->size = n - ((&ram_94860 - RHYTHM_PATTERN_BUF_A) + (&ram_95bc0 - &ram_94860));
	}
}
