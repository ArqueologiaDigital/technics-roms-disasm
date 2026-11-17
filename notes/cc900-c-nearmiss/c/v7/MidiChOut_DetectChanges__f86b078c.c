/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/audio_control_engine_m278.c (2026-11-16-122-p6-r24-staged)
   sha256 f86b078c6973b507872b88b6f8af8d16d95d8e5454252bd8fe388792dac731e1 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near PLAY_TRANSPORT_STATE;
extern unsigned char __near ram_33df;
extern unsigned int __near LED_REQUEST_2;
void MidiChOut_DetectChanges(void)
{
	if (ACC_TRANSPORT_STATE & 4) return;
	if (!((PLAY_TRANSPORT_STATE ^ ram_33df) & 4)) return;
	LED_REQUEST_2 |= 4;
	ram_33df = PLAY_TRANSPORT_STATE;
}
