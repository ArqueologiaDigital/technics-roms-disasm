/* Phase 6, lane_p6 helper D, round 16, module 278 (v10 audio/audio_control_engine.s), form a (poolmm_D):
   MidiChOut_DetectChanges -- when the accompaniment is not running and bit 2 of the play transport changed since the
   copy at 0x347b, requests LED group 2 bit 2 and updates the copy (a move between __near cells).  Form b
   (p6_D_16m278b.c) takes the transport into a local first. */

extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near PLAY_TRANSPORT_STATE;
extern unsigned char __near ram_347b;
extern unsigned int __near LED_REQUEST_2;

void MidiChOut_DetectChanges(void)
{
	if (ACC_TRANSPORT_STATE & 4) return;
	if (!((PLAY_TRANSPORT_STATE ^ ram_347b) & 4)) return;
	LED_REQUEST_2 |= 4;
	ram_347b = PLAY_TRANSPORT_STATE;
}
