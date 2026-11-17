/* Phase 6, lane_p6 helper G, round 12, FORM B of p6_G_12a.c (whose notes describe the routine):
   MidiPkt_ProcessEventQueue with SeqVoice_StoreEntry returning the 4-byte record itself (a struct return in XHL),
   assigned to the 0xbd22 cell as a struct. */

struct mev { unsigned char type, d1, d2, d3; };

extern unsigned char __near PANEL_MIDI[];
extern unsigned char __near ram_b7e7;
extern unsigned int __near ram_90e0;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern struct mev __near ram_bd22;
extern void (*MidiPkt_EventType_Table[])(void);
extern struct mev __cdecl SeqVoice_StoreEntry(unsigned char *);

void MidiPkt_ProcessEventQueue(void)
{
	unsigned char *p;

	if (PANEL_MIDI[0] & 0x10) return;
	if (!(PANEL_MIDI[6] & 8)) return;
	if (ram_b7e7 & 1) return;
	p = SWBTWR_EVENT_QUEUE + ram_90e0;
	for (;;) {
		ram_bd22 = SeqVoice_StoreEntry(p);
		if (ram_bd22.type == 0xff) return;
		if (ram_bd22.type < 0xc0) MidiPkt_EventType_Table[ram_bd22.type]();
		p += 4;
	}
}
