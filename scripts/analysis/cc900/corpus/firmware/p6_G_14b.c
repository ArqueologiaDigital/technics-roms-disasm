/* Phase 6, lane_p6 helper G, round 14, FORM B of p6_G_14a.c (whose notes say what each spot tries):
   MidiPkt_ProcessEventQueue with the start entry `(unsigned char *)SWBTWR_EVENT_QUEUE + ram_90e0` and the handler
   offset written `(long)((int)e->type << 2)` added after the table's address. */

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
	p = (unsigned char *)SWBTWR_EVENT_QUEUE + ram_90e0;
	for (;;) {
		ram_bd22 = SeqVoice_StoreEntry(p);
		e = &ram_bd22;
		if (e->type == 0xff) break;
		if (e->type < 0xc0) (*(evfn *)((long)((int)e->type << 2) + (char *)MidiPkt_EventType_Table))();
		p += 4;
	}
}
