/* Phase 6, lane_p6 helper L, round 4, form a: module 235.  Retry of SeqVoice_ComputeStatusFlags (r43 Xr +8: the
   shift).  The ROM sets the bit to 1 before reading t and shifts by t with one `and a,15; jr z` (helper M: a
   variable shift gets V4.23's own mask), so `m = 1; m <<= t;`.  Status assigned in every branch (no
   initialiser: the ROM keeps it in C, not in a saved register); a switch with 0x9a as the last case (compared
   first), the 0x85 / 0x87 and 0x78 / 0x7a / 0x81 groups before it, for O3Xr. */
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
