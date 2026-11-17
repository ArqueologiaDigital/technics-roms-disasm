/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/audio_control_engine_m278.c (2026-11-16-68-p6-r12)
   sha256 e9b87df03ca0c26b8a9cc22a4d78c8cf3389c2e176aeffbf545c3e51a70e5ccc (tar-sha256); compiled at -O3 -Xr
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
