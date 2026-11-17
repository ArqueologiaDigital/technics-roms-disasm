/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/audio_control_engine_m278.c (2026-11-16-68-p6-r12)
   sha256 931b31ee76072e32d9495b11e0a459d1361f35c4680409fd4c4e6be9267e234f (tar-sha256); compiled at -O3 -Xr
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
