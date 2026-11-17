/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/audio_control_engine_m278.c (2026-11-16-122-p6-r24-staged)
   sha256 a342709c8d4b63b8edb321b1ec1dd40c40d9b5614df3ec947371d86ae96be5f4 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near PLAY_TRANSPORT_STATE;
extern unsigned char __near ram_33c3;
extern unsigned int __near LED_REQUEST_2;
void MidiChOut_DetectChanges(void)
{
	if (ACC_TRANSPORT_STATE & 4) return;
	if (!((PLAY_TRANSPORT_STATE ^ ram_33c3) & 4)) return;
	LED_REQUEST_2 |= 4;
	ram_33c3 = PLAY_TRANSPORT_STATE;
}
