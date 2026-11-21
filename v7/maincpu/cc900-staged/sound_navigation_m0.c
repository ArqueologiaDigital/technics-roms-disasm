/* Functions of audio/sound_navigation.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

#define EVT_REQUEST_TRACK_SWITCH 0x1e00092L
#define EVT_TOGGLE_TRACK_SWITCH  0x1e00093L
extern void SeqVoice_DispatchEventToHandler(unsigned int);
extern void SeqVoice_ComputeStatusFlags(unsigned int);
extern void AppEvent_HandleChannelEvent(unsigned int);
long MainTrSwControl(long obj, long evt, long param);
extern long MainTrSwControl(long obj, long evt, long param);

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
