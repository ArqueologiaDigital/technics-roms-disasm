/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_ui_m232.c (2026-11-21-22-p6-r67)
   sha256 d1c85ffe17f3e1837f624634943d99837086bdf57f402be48054db6d0ef23b84 (tar-sha256); compiled at -Xr
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
