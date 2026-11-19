/* Phase 6, lane_p6 helper L, round 4, form b: module 235, SeqVoice_ComputeStatusFlags as round 2's if chain (best at
   Xr) with only the shift changed to `m = 1; m <<= t;`. */
/* (no module-local callee) */

#define EVT_TRSW_COMMAND 0x1c0002eL
extern unsigned char __near ACTIVE_TITLE;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int __near SQEDT_TRKCLR_MASK;
extern int Part_IsVoiceActive(unsigned int);
extern long ApPostEvent(long, long, long);
extern void SeqVoice_ComputeStatusFlags(unsigned char t);

void SeqVoice_ComputeStatusFlags(unsigned char t)
{
	unsigned char title;
	unsigned int m;
	unsigned char s;

	title = ACTIVE_TITLE;
	m = 1;
	m <<= t;
	if (title == 0x9a) {
		if (m & SQEDT_TRKCLR_MASK)
			s = 4;
		else
			s = 0;
	} else if (title == 0x87 || title == 0x85) {
		if (m & SEQ_REC_TRACKS)
			s = 1;
		else if ((m & SEQ_TRACK_MASK) != 0 && Part_IsVoiceActive(t + 1) != 0)
			s = 2;
		else
			s = 0;
	} else if (title == 0x7a || title == 0x78 || title == 0x81) {
		if ((m & SEQ_TRACK_MASK) != 0 && Part_IsVoiceActive(t + 1) != 0)
			s = 2;
		else
			s = 0;
	} else
		s = 0;
	ApPostEvent(-1, EVT_TRSW_COMMAND, ((unsigned long)t << 16) + s);
}
