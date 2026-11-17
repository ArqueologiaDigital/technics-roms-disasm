/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/audio_control_engine_m278.c (2026-11-16-122-p6-r24-staged)
   sha256 37fe2fae9d8f9b59820dcaf4cc55f1440f5f6ae3979b746fd80a43ed9c0ff50e (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
