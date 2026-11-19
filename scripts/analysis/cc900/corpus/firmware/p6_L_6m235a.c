/* Phase 6, lane_p6 helper L, round 6, form a: module 235.  Retry of SeqVoice_ComputeStatusFlags (r47 O3Xr +8: the
   title is in E now; the bit went to HL where the ROM has BC).  In the ROM the status is set by `ld c,N` with one
   `ld b,0` at the merge, i.e. the status is the SAME int variable as the bit (idiom 4: a variable reused for two
   purposes keeps one register).  One int v for both. */
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
	unsigned int v;

	title = ACTIVE_TITLE;
	v = 1;
	v <<= t;
	switch (title) {
	case 0x81:
	case 0x78:
	case 0x7a:
		if ((v & SEQ_TRACK_MASK) != 0 && Part_IsVoiceActive(t + 1) != 0)
			v = 2;
		else
			v = 0;
		break;
	case 0x85:
	case 0x87:
		if (v & SEQ_REC_TRACKS)
			v = 1;
		else if ((v & SEQ_TRACK_MASK) != 0 && Part_IsVoiceActive(t + 1) != 0)
			v = 2;
		else
			v = 0;
		break;
	case 0x9a:
		if (v & SQEDT_TRKCLR_MASK)
			v = 4;
		else
			v = 0;
		break;
	default:
		v = 0;
	}
	ApPostEvent(-1, EVT_TRSW_COMMAND, ((unsigned long)t << 16) + v);
}
