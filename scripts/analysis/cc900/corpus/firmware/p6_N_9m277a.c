/* lane_p6 helper N, round 9, form a: module 277 (audio/tonegen_fileio_handlers.s), retry of p6_N_8m277a
   (p6-r52 Xr: +26).  PanelButton_ProcessChanges: the ROM widens the entry number before multiplying it signed
   (extz wa; muls wa,3), V4.23 multiplied the byte and widened after: the index written `(int)ram_8e8c * 3`.
   Below it the new PanelInput_QueueCpuAdcChanges (audio/audio_control_engine.s, same module).
   cc900-options: -Xr
*/
/* cc900-module: PanelButton_DispatchChange PanelButton_FetchChange PanelInput_QueueChange VoiceEntry_FindMasterVolume */

struct pevt { unsigned char code, a, b, c; };
extern unsigned char __near ram_8e8c;
extern unsigned char __near ram_8e8e;
extern unsigned char __near ram_8e90;
extern struct pevt __near PANEL_EVENT_QUEUE[];
extern unsigned char *PanelInput_ChangeQueue(void);
extern void PanelButton_FetchChange(void);
extern void PanelButton_DispatchChange(void);
extern void PanelInput_ClearChangeQueue(void);
extern void VoiceEntry_FindMasterVolume(void);

void PanelButton_ProcessChanges(void)
{
	ram_8e8c = 0;
	ram_8e8e = 0;
	while ((ram_8e90 = PanelInput_ChangeQueue()[(int)ram_8e8c * 3]) != 0xff) {
		PanelButton_FetchChange();
		PanelButton_DispatchChange();
	}
	PANEL_EVENT_QUEUE[ram_8e8e].code = 0xff;
	PanelInput_ClearChangeQueue();
	VoiceEntry_FindMasterVolume();
}

/* PanelInput_QueueCpuAdcChanges (new): while the panel change queue (count 0x8ec4) has room, queues a pending
   expression-pedal (0x1a) and after-touch (0x1b) value -- bit 7 of the ADC output's flag byte, cleared when
   taken -- as a 3-byte change {code, value, 0x7f} built at 0x8eb2. */
extern unsigned char __near ram_8eb2[];
extern unsigned char __near ram_8ec4;
extern unsigned char __near ADC_AN0_OUTPUT[];
extern unsigned char __near ADC_AN1_OUTPUT[];
extern void PanelInput_QueueChange(unsigned char *);

void PanelInput_QueueCpuAdcChanges(void)
{
	unsigned char *q;
	unsigned char *a;

	q = ram_8eb2;
	if (ram_8ec4 < 7) {
		a = ADC_AN0_OUTPUT;
		if (a[1] & 0x80) {
			a[1] &= ~0x80;
			q[0] = 0x1a;
			q[1] = a[0];
			q[2] = 0x7f;
			PanelInput_QueueChange(q);
		}
	}
	if (ram_8ec4 < 7) {
		a = ADC_AN1_OUTPUT;
		if (a[1] & 0x80) {
			a[1] &= ~0x80;
			q[0] = 0x1b;
			q[1] = a[0];
			q[2] = 0x7f;
			PanelInput_QueueChange(q);
		}
	}
}
