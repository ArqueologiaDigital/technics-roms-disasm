/* Phase 6, lane_p6 helper L, round 2, form b: module 235, SeqVoice_ComputeStatusFlags with the 0x9a test as an if and
   the rest as a switch written in ascending order (V4.23 compares the last case first: 0x87, 0x85, 0x7a, 0x78,
   0x81 in the ROM), status in a local initialised to 0. */
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
	s = 0;
	if (title == 0x9a) {
		if (m & SQEDT_TRKCLR_MASK)
			s = 4;
	} else
		switch (title) {
		case 0x81:
		case 0x78:
		case 0x7a:
			if ((m & SEQ_TRACK_MASK) != 0 && Part_IsVoiceActive(t + 1) != 0)
				s = 2;
			break;
		case 0x85:
		case 0x87:
			if (m & SEQ_REC_TRACKS)
				s = 1;
			else if ((m & SEQ_TRACK_MASK) != 0 && Part_IsVoiceActive(t + 1) != 0)
				s = 2;
			break;
		}
	ApPostEvent(-1, EVT_TRSW_COMMAND, ((unsigned long)t << 16) + s);
}
