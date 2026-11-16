/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_4b.c (2026-11-16-40-p6-r8)
   sha256 3f9699055ea8ee760c6182765bb0c18af9ae963c90014c6f6548598332507ab7 (tar-sha256); compiled at -O3 -XS -Xr */
extern void *DspFxRecListPtrTable[];
int DSPCfg_CheckParamTableEntry(unsigned int a)
{
	int r = 0;

	if (a > 0x63) goto nf;
	if (DspFxRecListPtrTable[a] != 0) return r;
nf:
	return -1;
}
