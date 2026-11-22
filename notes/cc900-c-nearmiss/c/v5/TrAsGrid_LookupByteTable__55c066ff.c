/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_ui_m232.c (2026-11-22-1-p6-r69)
   sha256 55c066ff9ebf29a7451f03822bc79f46114d349059f1d8190ae2a891f71f44e1 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_TRACK_ASSIGN[];
unsigned char TrAsGrid_LookupByteTable(unsigned char i)
{
	return SEQ_TRACK_ASSIGN[i];
}
