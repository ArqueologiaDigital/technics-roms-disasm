/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/dsp_config_sysex.c (2026-11-16-55-p6-r10)
   sha256 6a6972cee17a23516dd178e3601617eda9e6068d4bf8e1f38c02f69113075362 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char DspFxParamCountTable[], DspCfg_Data002_ByteTable[];
unsigned int DSPCfg_GetSlotCount(unsigned int i)
{
	return DspFxParamCountTable[i];
}
