/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_13b.c (2026-11-17-16-p6-r31)
   sha256 54862b35a3602bb9b131174d18aaac181723b758b82fba09afd7fcbd7f19f472 (tar-sha256); compiled at -Xr */
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
	p = &SWBTWR_EVENT_QUEUE[ram_90e0];
	for (;;) {
		ram_bd22 = SeqVoice_StoreEntry(p);
		e = &ram_bd22;
		if (e->type == 0xff) break;
		if (e->type < 0xc0) (*(evfn *)((long)(e->type * 4) + (char *)MidiPkt_EventType_Table))();
		p += 4;
	}
}
