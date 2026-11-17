/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/audio_control_engine.c (2026-11-16-55-p6-r10)
   sha256 f37d04d4cf90e9f65661b261fe9b19bca25c73b38a3503e1a3cbaeeee2a9f164 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_8eb0;
extern unsigned char __near DEMO_PLAY_STATE;
extern unsigned char __near ram_8eb4;
extern unsigned char __near ram_8eb6;
extern unsigned char __near ram_8eb8;
extern unsigned char __near ram_8eba;
void Audio_InitChannelTimers(void)
{
	ram_8eb0 = 5;
	DEMO_PLAY_STATE = 5;
	ram_8eb4 = 5;
	ram_8eb6 = 5;
	ram_8eb8 = 5;
	ram_8eba = 5;
}
