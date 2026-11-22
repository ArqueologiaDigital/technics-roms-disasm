/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sound_navigation_m0.c (2026-11-21-22-p6-r67)
   sha256 62c77d7893afd090462def9b03474bab94ad866c9c0e9cf09a38c87db2d0e1ae (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_REQUEST_TRACK_SWITCH 0x1e00092L
#define EVT_TOGGLE_TRACK_SWITCH  0x1e00093L
extern void SeqVoice_DispatchEventToHandler(unsigned int);
extern void SeqVoice_ComputeStatusFlags(unsigned int);
extern void AppEvent_HandleChannelEvent(unsigned int);
long MainTrSwControl(long obj, long evt, long param)
{
	switch (evt) {
	case EVT_REQUEST_TRACK_SWITCH:
		SeqVoice_DispatchEventToHandler((unsigned char)param);
		SeqVoice_ComputeStatusFlags((unsigned char)param);
		break;
	case EVT_TOGGLE_TRACK_SWITCH:
		AppEvent_HandleChannelEvent((unsigned char)param);
		break;
	}
	return 0;
}
