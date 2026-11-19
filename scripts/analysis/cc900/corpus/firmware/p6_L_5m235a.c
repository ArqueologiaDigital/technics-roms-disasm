/* Phase 6, lane_p6 helper L, round 5, form a: module 235.  Retry of SeqVoice_ComputeStatusFlags at O3Xr (r46 form a
   +7: title in L and the bit in DE where the ROM has E and BC).  Same switch, locals declared bit, status, title
   (idiom 4: declaration order moves the register choice). */
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
	unsigned int m;
	unsigned char s;
	unsigned char title;

	title = ACTIVE_TITLE;
	m = 1;
	m <<= t;
	switch (title) {
	case 0x81:
	case 0x78:
	case 0x7a:
		if ((m & SEQ_TRACK_MASK) != 0 && Part_IsVoiceActive(t + 1) != 0)
			s = 2;
		else
			s = 0;
		break;
	case 0x85:
	case 0x87:
		if (m & SEQ_REC_TRACKS)
			s = 1;
		else if ((m & SEQ_TRACK_MASK) != 0 && Part_IsVoiceActive(t + 1) != 0)
			s = 2;
		else
			s = 0;
		break;
	case 0x9a:
		if (m & SQEDT_TRKCLR_MASK)
			s = 4;
		else
			s = 0;
		break;
	default:
		s = 0;
	}
	ApPostEvent(-1, EVT_TRSW_COMMAND, ((unsigned long)t << 16) + s);
}
