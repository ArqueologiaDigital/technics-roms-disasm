/* Functions of audio/dsp_config_sysex.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern void *DspFxRecListPtrTable[];

int DSPCfg_CheckParamTableEntry(unsigned int a)
{
	int r = 0;

	if (a > 0x63) goto nf;
	if (DspFxRecListPtrTable[a] != 0) return r;
nf:
	return -1;
}
