/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_ui_m0_b.c (2026-11-22-1-p6-r69)
   sha256 a507b7d7fa551fe6bb96cf0d9432c89738520876603aed1ab15b6efe11df9e77 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned int ram_21086;
long SMFMute_GetUpperBits(void)
{
	return ram_21086 & 0xfffc;
}
