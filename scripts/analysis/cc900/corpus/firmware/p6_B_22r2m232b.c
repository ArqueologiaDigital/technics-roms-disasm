/* lane_p6 helper B, round 22r2, form b: module 232 (sequencer/sequencer_ui.s), TrAsGrid_CheckTrackType as in form
   a, but one type local chosen by an if / else and one test (V4.23 may duplicate the test into both paths as the
   ROM has it).
   cc900-options: -O3 -Xr
*/

extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned char ram_21082;

unsigned char TrAsGrid_CheckTrackType(unsigned char sel, unsigned char trk);

unsigned char TrAsGrid_CheckTrackType(unsigned char sel, unsigned char trk)
{
	unsigned char t;
	if (sel == 0) t = SEQ_TRACK_ASSIGN[trk];
	else t = ram_21082;
	if (t == 0xe || t == 0xd) return 1;
	return 0;
}

/* AcModeSelBoxProc (f2c99d): as in form a, written as an early return for the other events and a view-instance
   pointer local. */
#define EVT_SET_SELECTED 0x1e0004dL
extern unsigned char __near ram_d3e;
extern long InheritedProc(long, long, long);
extern unsigned char *GetViewInstance(long);
long AcModeSelBoxProc(long obj, long evt, long param);

long AcModeSelBoxProc(long obj, long evt, long param)
{
	unsigned char *v;
	if (evt != EVT_SET_SELECTED) return InheritedProc(obj, evt, param);
	InheritedProc(obj, evt, param);
	if (param == 1) {
		v = GetViewInstance(obj);
		ram_d3e = v[0x32];
	}
	return 0;
}
