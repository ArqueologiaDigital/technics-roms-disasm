/* Phase 6, lane_p6 helper G, round 13, form a: MidiPkt_ProcessEventQueue (midi/midipkt_routines.s; the routine's
   notes are in round 12's p6_G_12a.c).  Run 2026-11-17-2-p6-r29 gave +6 at Xr (O3Xr also shares &PANEL_MIDI in a
   register, which the ROM does not).  Three spots at Xr:
   1. the ROM takes the queue's base (lda) before the start index, then adds the index to it in IZ: here the index is
      written first (`ram_90e0 + SWBTWR_EVENT_QUEUE`; form b `&SWBTWR_EVENT_QUEUE[ram_90e0]`);
   2. the ROM tests and reads the copied record through its address in XWA (lda once, two compares and the load),
      and leaves the loop to the shared `pop xiz; ret`, where V4.23 gave each `return` its own epilogue: here the
      record is read through a pointer local `e`, and the loop ends with `break`;
   3. the ROM widens the table offset (type * 4, an int) to long and adds the table's address (exts, add), where
      V4.23 indexed with a 16-bit register: here the table is read through a cast pointer (form b: a byte offset
      converted to long and added to the table's address). */

struct mev { unsigned char type, d1, d2, d3; };
typedef void (*evfn)(void);

extern unsigned char __near PANEL_MIDI[];
extern unsigned char __near ram_b7e7;
extern unsigned int __near ram_90e0;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern struct mev __near ram_bd22;
extern long MidiPkt_EventType_Table[];
extern struct mev __cdecl SeqVoice_StoreEntry(unsigned char *);

void MidiPkt_ProcessEventQueue(void)
{
	unsigned char *p;
	struct mev *e;

	if (PANEL_MIDI[0] & 0x10) return;
	if (!(PANEL_MIDI[6] & 8)) return;
	if (ram_b7e7 & 1) return;
	p = ram_90e0 + SWBTWR_EVENT_QUEUE;
	for (;;) {
		ram_bd22 = SeqVoice_StoreEntry(p);
		e = &ram_bd22;
		if (e->type == 0xff) break;
		if (e->type < 0xc0) ((evfn *)MidiPkt_EventType_Table)[e->type]();
		p += 4;
	}
}
