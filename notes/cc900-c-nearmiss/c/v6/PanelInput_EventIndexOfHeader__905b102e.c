/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/audio_control_engine.c (2026-11-16-55-p6-r10)
   sha256 905b102ec67db05241a7bb46d72e45cb08dfa79fb3ce724d46d401b5490c3eb7 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char PanelInput_EventIndexByHeader[];
unsigned char PanelInput_EventIndexOfHeader(unsigned char h)
{
	return PanelInput_EventIndexByHeader[(h & 0xc0) >> 1 | (h & 0x1f)];
}
