/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_5m235a.c (2026-11-19-37-p6-r47)
   sha256 be78d16bae85f7aad61a9f2c1d6defd9b93e75e815fdc5aef6b103c0c3e4ec11 (tar-sha256); compiled at -O3 -Xr */
#define EVT_TRSW_COMMAND 0x1c0002eL
extern unsigned char __near ACTIVE_TITLE;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int __near SQEDT_TRKCLR_MASK;
extern int Part_IsVoiceActive(unsigned int);
extern long ApPostEvent(long, long, long);
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
