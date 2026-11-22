/* lane_p6 helper U, round 32r1: roots of audio/audio_control_engine.s, module 278 (-O3 -Xr). */
/* cc900-module: Audio_CheckAndFlagChanges DispatchBitmaskHandlers MidiChOut_DetectChanges */

struct Led_s {
	unsigned char hi : 4;
	unsigned char lo : 4;
};

extern unsigned char __near CPANEL_LED_IMAGE[];
extern unsigned char __near ram_8e76;
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near ACC_BEAT;
extern unsigned char __near ACC_CLOCK;
extern unsigned char __near ACC_BEATS_PER_BAR;
extern unsigned char BeatLed_ThreeBeatMasks[];
extern unsigned char BeatLed_FourBeatMasks[];
extern unsigned int __near LED_REQUEST_HOLD_2;
extern unsigned char __near ram_8f4a;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned int __near ram_40f;
extern int SndParam_LookupReadOnly(long);
extern void MidiChOut_DetectChanges(void);
extern unsigned char __near CURRENT_TITLE;
extern unsigned int __near LED_REQUEST_1;
extern unsigned int __near LED_REQUEST_HOLD_1;
extern unsigned int __near LED_REQUEST_2;
extern unsigned int __near LED_REQUEST_3;
extern unsigned int __near LED_REQUEST_HOLD_3;
extern unsigned int __near ram_8f46;
extern unsigned int __near ram_8f48;
extern void (*PanelLed_PendingGroup1Handlers[])(void);
extern void (*PanelLed_PendingGroup2Handlers[])(void);
extern void (*PanelLed_PendingGroup3Handlers[])(void);
extern void (*PanelLed_PendingGroup4Handlers[])(void);
extern void Audio_CheckAndFlagChanges(void);
extern void DispatchBitmaskHandlers(unsigned int, void (**)(void));

void MIDI_ProcessChangedChannels(void)
{
	unsigned int m;

	if (CURRENT_TITLE == 251) return;
	Audio_CheckAndFlagChanges();
	if ((m = ~LED_REQUEST_HOLD_1 & LED_REQUEST_1) != 0) {
		DispatchBitmaskHandlers(m, PanelLed_PendingGroup1Handlers);
		LED_REQUEST_1 = 0;
	}
	if ((m = ~LED_REQUEST_HOLD_2 & LED_REQUEST_2) != 0) {
		DispatchBitmaskHandlers(m, PanelLed_PendingGroup2Handlers);
		LED_REQUEST_2 = 0;
	}
	if ((m = ~LED_REQUEST_HOLD_3 & LED_REQUEST_3) != 0) {
		DispatchBitmaskHandlers(m, PanelLed_PendingGroup3Handlers);
		LED_REQUEST_3 = 0;
	}
	if ((m = ~ram_8f48 & ram_8f46) != 0) {
		DispatchBitmaskHandlers(m, PanelLed_PendingGroup4Handlers);
		ram_8f46 = 0;
	}
}

void MidiChannel_ProcessOutputState(void)
{
	unsigned char *p;
	struct Led_s *q;
	unsigned char c;
	unsigned char l;
	unsigned char b;
	unsigned char *t;

	p = CPANEL_LED_IMAGE;
	MidiChOut_DetectChanges();
	q = (struct Led_s *)(p + 14);
	c = ram_8e76;
	if (!(ACC_TRANSPORT_STATE & 4)) {
		if (!(c & 2)) return;
		ram_8e76 = c & ~2;
		q->lo = 0;
		return;
	}
	l = ACC_BEAT;
	if (ACC_CLOCK & 0x60) {
		if (!(c & 2)) return;
		ram_8e76 = c & ~2;
		q->lo = 0;
		return;
	}
	ram_8e76 |= 2;
	b = ACC_BEATS_PER_BAR;
	if (b == 6 || b == 3) {
		l &= 7;
		t = BeatLed_ThreeBeatMasks;
	} else {
		l &= 3;
		t = BeatLed_FourBeatMasks;
	}
	q->lo = t[l];
}

void MidiChannel_ScanPending(void)
{
	unsigned char *p;
	unsigned char *q;
	int r;

	p = CPANEL_LED_IMAGE;
	if (LED_REQUEST_HOLD_2 & 4) return;
	if (ram_8f4a & 3) return;
	if (ACC_TRANSPORT_STATE & 4) return;
	if (SEQ_RTMCFG & 4) {
		if (SEQ_TRANSPORT_STATE & 4) return;
		p[14] &= 0xf0;
		return;
	}
	r = SndParam_LookupReadOnly(0x28103L);
	q = p + 14;
	if (r == 1) {
		if (!(ram_40f & 0x40)) {
			*q = (*q & 0xf0) | 1;
			return;
		}
	} else {
		if (SEQ_TRANSPORT_STATE & 4) return;
	}
	*q &= 0xf0;
}
