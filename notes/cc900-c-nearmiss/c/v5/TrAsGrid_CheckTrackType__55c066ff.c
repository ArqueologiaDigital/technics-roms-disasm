/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_ui_m232.c (2026-11-21-22-p6-r67)
   sha256 55c066ff9ebf29a7451f03822bc79f46114d349059f1d8190ae2a891f71f44e1 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned char ram_212857;
unsigned char TrAsGrid_CheckTrackType(unsigned char sel, unsigned char trk)
{
	if (sel == 0) {
		unsigned char t = SEQ_TRACK_ASSIGN[trk];
		if (t == 0xe || t == 0xd) return 1;
	} else {
		unsigned char t = ram_212857;
		if (t == 0xe || t == 0xd) return 1;
	}
	return 0;
}
