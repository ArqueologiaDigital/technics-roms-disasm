/* Phase 6, lane_p6 helper L, round 2, form a: module 235 (sequencer/sequencer_engine.s).
   - SeqVoice_ComputeStatusFlags: track t's switch status for the current title (0x9a: cleared track 4; 0x87 /
     0x85: recording 1, else sounding 2; 0x7a / 0x78 / 0x81: sounding 2; else 0), posted as EVT_TRSW_COMMAND with
     (t << 16) + status.  The track bit is 1 << (t & 15) (sla by a count, skipped for 0).  The ROM computes the
     Part_IsVoiceActive argument t + 1 once after the 0x9a test (O3 hoisting).  Form a: if chain. */
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
	m = 1 << (t & 0xf);
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
