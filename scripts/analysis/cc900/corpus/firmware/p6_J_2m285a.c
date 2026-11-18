/* Phase 6, lane_p6 helper J, round 2, module 285 (midi/midi_dispatch_handlers.s, -O3 -Xr), form a:
   MidiPkt_SetXferBlock_AccompBlockPool, written like the matched MidiPkt_SetXferBlock_CurrentSong.  Block 3 of the
   accompaniment-area transfer: {0x1e8b00, +0x3900, 0x3900}; with bit 6 of 0xbd18 the used size less blocks 1-2.
   The ROM computes blocks 1-2 as (0x1e8820 - 0x1e8800) + (0x1e8b00 - 0x1e8820), the right difference first. */
/* cc900-module: MidiPkt_GetUsedSize_AccompBlocks */   /* scripts/analysis/cc900/module_calls.py v10 */

struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char ram_1e8b00, ram_1e8820, MSP_SETTINGS__BASE_ADDR;
extern unsigned char __near ram_bd18;
extern long MidiPkt_GetUsedSize_AccompBlocks(void);

void MidiPkt_SetXferBlock_AccompBlockPool(struct xfer *x)
{
	long used;
	long hdr;

	x->end = (x->start = &ram_1e8b00) + 0x3900;
	x->size = 0x3900;
	if (ram_bd18 & 0x40) {
		used = MidiPkt_GetUsedSize_AccompBlocks();
		hdr = (&ram_1e8820 - &MSP_SETTINGS__BASE_ADDR) + (&ram_1e8b00 - &ram_1e8820);
		x->end = x->start + used - hdr;
		x->size = used - hdr;
	}
}
