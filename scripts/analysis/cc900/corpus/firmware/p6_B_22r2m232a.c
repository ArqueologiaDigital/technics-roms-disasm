/* lane_p6 helper B, round 22r2, form a: module 232 (sequencer/sequencer_ui.s), TrAsGrid_CheckTrackType, the first
   root of roots23_B's pooled stretch at f2c446 (TrAsGridCheck after it is a 7-case switch whose case bodies share
   blocks across cases; left for a later round).  In: A = selector, C = track; L = 1 for a drum track type
   (0x0d / 0x0e), else 0.
   Form a: the test written in each branch (the ROM repeats it), block-scoped type locals.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned char ram_21082;

unsigned char TrAsGrid_CheckTrackType(unsigned char sel, unsigned char trk);

unsigned char TrAsGrid_CheckTrackType(unsigned char sel, unsigned char trk)
{
	if (sel == 0) {
		unsigned char t = SEQ_TRACK_ASSIGN[trk];
		if (t == 0xe || t == 0xd) return 1;
	} else {
		unsigned char t = ram_21082;
		if (t == 0xe || t == 0xd) return 1;
	}
	return 0;
}

/* AcModeSelBoxProc (f2c99d, the last root of the same stretch): passes every event to InheritedProc; on
   EVT_SET_SELECTED with parameter 1 it also copies byte 0x32 of the view instance to RAM 0x0d3e (the ROM's
   memory-to-memory `ld (0x0d3e), (xhl+0x32)`, held as the mrdb5 macro) and returns 0.
   Form a: a one-case switch with the default written first. */
#define EVT_SET_SELECTED 0x1e0004dL
extern unsigned char __near ram_d3e;
extern long InheritedProc(long, long, long);
extern unsigned char *GetViewInstance(long);
long AcModeSelBoxProc(long obj, long evt, long param);

long AcModeSelBoxProc(long obj, long evt, long param)
{
	switch (evt) {
	default:
		return InheritedProc(obj, evt, param);
	case EVT_SET_SELECTED:
		InheritedProc(obj, evt, param);
		if (param == 1) ram_d3e = GetViewInstance(obj)[0x32];
		break;
	}
	return 0;
}
