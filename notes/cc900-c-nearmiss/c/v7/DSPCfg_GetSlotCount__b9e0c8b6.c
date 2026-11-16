/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/dsp_config_sysex_m293.c (2026-11-16-68-p6-r12)
   sha256 b9e0c8b6d4d15d68f3e76ece19c0cefb7c22d889fb2d9cebb806d07352a087cf (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char DspFxParamCountTable[], DspCfg_Data002_ByteTable[];
unsigned int DSPCfg_GetSlotCount(unsigned int i)
{
	return DspFxParamCountTable[i];
}
