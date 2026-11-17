/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/audio_control_engine.c (2026-11-16-55-p6-r10)
   sha256 eb272322a9ca5cd5672dea3f898fbc1c871c8ab00549b22bdff756d69d49a438 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char PanelInput_EventIndexByHeader[];
unsigned char PanelInput_EventIndexOfHeader(unsigned char h)
{
	return PanelInput_EventIndexByHeader[(h & 0xc0) >> 1 | (h & 0x1f)];
}
