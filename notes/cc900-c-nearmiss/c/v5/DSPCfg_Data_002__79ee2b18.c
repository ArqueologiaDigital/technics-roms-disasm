/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/dsp_config_sysex_m0.c (2026-11-16-68-p6-r12)
   sha256 79ee2b1854057e38c10ba619b34559391be22824054ae14bc98ce21cb7abec4a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char DspFxParamCountTable[], DspCfg_Data002_ByteTable[];
unsigned int DSPCfg_Data_002(unsigned int i)
{
	return DspCfg_Data002_ByteTable[i];
}
