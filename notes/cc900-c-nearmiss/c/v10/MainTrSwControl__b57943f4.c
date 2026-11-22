/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_22r2m270b.c (2026-11-21-21-p6-r66)
   sha256 b57943f4440a342f9582eab8b5106b936562db17f6ea8c655d9693d05d69c989 (tar-sha256); compiled at -Xr
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
