/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/audio_control_engine_m277.c (2026-11-16-68-p6-r12)
   sha256 d2a6853870aa0fbea69aa7a67b6960bba65bfe66fcb14d7937a24a3cdfc9f135 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char PanelInput_EventIndexByHeader[];
unsigned char PanelInput_EventIndexOfHeader(unsigned char h)
{
	return PanelInput_EventIndexByHeader[(h & 0xc0) >> 1 | (h & 0x1f)];
}
