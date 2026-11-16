/* Phase 6, lane_p6 helper D, round 16, module 278 (v10 audio/audio_control_engine.s), form b:
   MidiChOut_DetectChanges (see p6_D_16m278.c) with the changed bits in a local. */

extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near PLAY_TRANSPORT_STATE;
extern unsigned char __near ram_347b;
extern unsigned int __near LED_REQUEST_2;

void MidiChOut_DetectChanges(void)
{
	unsigned char d;

	if (ACC_TRANSPORT_STATE & 4) return;
	d = PLAY_TRANSPORT_STATE;
	d ^= ram_347b;
	if (d & 4) {
		LED_REQUEST_2 |= 4;
		ram_347b = PLAY_TRANSPORT_STATE;
	}
}
