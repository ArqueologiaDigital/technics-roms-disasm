/* lane_p6 helper N, round 6, form a: module 285 (midi/midi_dispatch_handlers.s), retry of p6_N_5m285a
   (p6-r47 Xr: +32).  MidiPkt_SetXferBlock_StyleImagePool: the ROM loads &0x94860 once, keeps the difference
   d in XDE, builds the end as start + n in XBC and the size in place on n; V4.23 parked d in XIX and summed
   n + start.  Form a: d declared before n, the end written `n + x->start`.
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
	long d;
	long n;

	x->end = (x->start = &ram_95bc0) + 0x15440;
	x->size = 0x15440;
	if (ram_bd18 & 0x40) {
		n = MidiPkt_GetUsedSize_StyleImage();
		d = (&ram_94860 - RHYTHM_PATTERN_BUF_A) + (&ram_95bc0 - &ram_94860);
		x->end = n + x->start - d;
		x->size = n - d;
	}
}
