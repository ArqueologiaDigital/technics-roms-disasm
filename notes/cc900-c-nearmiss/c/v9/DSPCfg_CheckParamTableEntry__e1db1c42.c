/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/dsp_config_sysex_xr.c (2026-11-16-45-p6-r9)
   sha256 e1db1c42090399866ed343d5966740e34f7f87cc0c88dc3d7ed85b5c26adfb1f (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern void *DspFxRecListPtrTable[];
int DSPCfg_CheckParamTableEntry(unsigned int a)
{
	int r = 0;

	if (a > 0x63) goto nf;
	if (DspFxRecListPtrTable[a] != 0) return r;
nf:
	return -1;
}
