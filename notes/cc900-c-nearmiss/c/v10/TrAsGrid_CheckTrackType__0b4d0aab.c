/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_22r2m232a.c (2026-11-21-21-p6-r66)
   sha256 0b4d0aab6bac0e5ba408e8121778b1c585ea2fcb78207abd2652f0081e3e5e2e (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned char ram_21082;
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
