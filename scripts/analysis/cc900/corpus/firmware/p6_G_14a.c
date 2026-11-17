/* Phase 6, lane_p6 helper G, round 14, form a: MidiPkt_ProcessEventQueue (the routine's notes: round 12's
   p6_G_12a.c).  Run 2026-11-17-16-p6-r31 (+19 at Xr): the record pointer and the `break` matched; two spots are left.
   1. The table read: the ROM widens the type to int (extz), shifts it as an int (sla 2), takes the table's address
      (lda), widens the offset to long (exts) and adds.  Round 13's form b (a byte offset converted to long) did the
      shift in 8 bits: here the type is cast to int first, `(long)((int)e->type * 4)`.
   2. The start entry: the ROM takes the queue's base first, then the index into IZ, extz, add; neither index-first
      spelling changed V4.23's order (index first).  Here the index is an explicit unsigned long,
      `SWBTWR_EVENT_QUEUE + (unsigned long)ram_90e0`; form b casts the base instead,
      `(unsigned char *)SWBTWR_EVENT_QUEUE + ram_90e0`. */

struct mev { unsigned char type, d1, d2, d3; };
typedef void (*evfn)(void);

extern unsigned char __near PANEL_MIDI[];
extern unsigned char __near ram_b7e7;
extern unsigned int __near ram_90e0;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern struct mev __near ram_bd22;
extern evfn MidiPkt_EventType_Table[];
extern struct mev __cdecl SeqVoice_StoreEntry(unsigned char *);

void MidiPkt_ProcessEventQueue(void)
{
	unsigned char *p;
	struct mev *e;

	if (PANEL_MIDI[0] & 0x10) return;
	if (!(PANEL_MIDI[6] & 8)) return;
	if (ram_b7e7 & 1) return;
	p = SWBTWR_EVENT_QUEUE + (unsigned long)ram_90e0;
	for (;;) {
		ram_bd22 = SeqVoice_StoreEntry(p);
		e = &ram_bd22;
		if (e->type == 0xff) break;
		if (e->type < 0xc0) (*(evfn *)((char *)MidiPkt_EventType_Table + (long)((int)e->type * 4)))();
		p += 4;
	}
}
