/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/audio_control_engine.c (2026-11-16-55-p6-r10)
   sha256 eb272322a9ca5cd5672dea3f898fbc1c871c8ab00549b22bdff756d69d49a438 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_8f4c;
extern unsigned char __near DEMO_PLAY_STATE;
extern unsigned char __near ram_8f50;
extern unsigned char __near ram_8f52;
extern unsigned char __near ram_8f54;
extern unsigned char __near ram_8f56;
void Audio_InitChannelTimers(void)
{
	ram_8f4c = 5;
	DEMO_PLAY_STATE = 5;
	ram_8f50 = 5;
	ram_8f52 = 5;
	ram_8f54 = 5;
	ram_8f56 = 5;
}
