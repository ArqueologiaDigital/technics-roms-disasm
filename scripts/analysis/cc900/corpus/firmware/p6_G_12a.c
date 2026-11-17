/* Phase 6, lane_p6 helper G, round 12, form a: MidiPkt_ProcessEventQueue (midi/midipkt_routines.s), new.
   Unless MIDI is switched off (PANEL_MIDI +0 bit 4 set, +6 bit 3 clear) or the flag at 0xb7e7 bit 0 is set, it walks
   the SwbtWr event queue from entry ram_90e0: each 4-byte entry is copied by SeqVoice_StoreEntry (hand assembly: one
   stacked pointer argument, the 4 bytes returned in XHL) into the cell at 0xbd22; type 0xff ends the walk, types
   below 0xc0 call MidiPkt_EventType_Table[type].  Read from the hand assembly: the entry pointer in XIZ; the
   0xbd22 cell's address computed once (lda) for the two type tests and the load; the table index widened int-wise
   (extz, sla 2, exts).  Cells reached with 16-bit operands are __near.  Form a stores the returned long through the
   cell's address; form b (p6_G_12b.c) declares the helper as returning the 4-byte record itself. */

struct mev { unsigned char type, d1, d2, d3; };

extern unsigned char __near PANEL_MIDI[];
extern unsigned char __near ram_b7e7;
extern unsigned int __near ram_90e0;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern struct mev __near ram_bd22;
extern void (*MidiPkt_EventType_Table[])(void);
extern unsigned long __cdecl SeqVoice_StoreEntry(unsigned char *);

void MidiPkt_ProcessEventQueue(void)
{
	unsigned char *p;

	if (PANEL_MIDI[0] & 0x10) return;
	if (!(PANEL_MIDI[6] & 8)) return;
	if (ram_b7e7 & 1) return;
	p = SWBTWR_EVENT_QUEUE + ram_90e0;
	for (;;) {
		*(unsigned long *)&ram_bd22 = SeqVoice_StoreEntry(p);
		if (ram_bd22.type == 0xff) return;
		if (ram_bd22.type < 0xc0) MidiPkt_EventType_Table[ram_bd22.type]();
		p += 4;
	}
}
