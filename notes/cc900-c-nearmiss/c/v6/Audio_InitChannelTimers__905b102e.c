/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/audio_control_engine.c (2026-11-16-55-p6-r10)
   sha256 905b102ec67db05241a7bb46d72e45cb08dfa79fb3ce724d46d401b5490c3eb7 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_8e8c;
extern unsigned char __near DEMO_PLAY_STATE;
extern unsigned char __near ram_8e90;
extern unsigned char __near ram_8e92;
extern unsigned char __near ram_8e94;
extern unsigned char __near ram_8e96;
void Audio_InitChannelTimers(void)
{
	ram_8e8c = 5;
	DEMO_PLAY_STATE = 5;
	ram_8e90 = 5;
	ram_8e92 = 5;
	ram_8e94 = 5;
	ram_8e96 = 5;
}
