/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_6a.c (2026-11-16-73-sub-r6)
   sha256 1249326f8ca11987596854d16d2a694ae8f2a5dc0418eaae612666ec2f2e7448 (name+funcs); compiled at -Xr */
extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern void DSP_WriteParamWord(long v, int chip);
void DSP_WriteParamCmd30(int chip, unsigned int b, long v)
{
    DSP_DispatchCommand(0x30, chip);
    DSP_DispatchData(0, chip);
    DSP_DispatchData((unsigned char)b, chip);
    DSP_WriteParamWord(v, chip);
}
