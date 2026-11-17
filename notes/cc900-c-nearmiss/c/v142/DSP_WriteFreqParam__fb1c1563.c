/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_6b.c (2026-11-16-73-sub-r6)
   sha256 fb1c1563ed8850e15aa1e32d11bf5d2b2bb7c77f193680f3555aae9537d41b3f (name+funcs); compiled at -Xr */
extern int DSP_DispatchData(int d, int chip);
extern void DSP_WriteParamCmd30(int chip, unsigned int b, long v);
void DSP_WriteFreqParam(unsigned int a, long v, int chip, unsigned int base)
{
    if (chip == 1) {
        DSP_WriteParamCmd30(chip, a, v);
    } else {
        DSP_DispatchData(0, chip);
        DSP_DispatchData(0, chip);
        DSP_DispatchData((unsigned char)((((base + a) >> 4) & 0xf) + 0x10), chip);
        DSP_DispatchData((unsigned char)(((base + a) << 4) & 0xf0), chip);
        DSP_DispatchData(0, chip);
        DSP_DispatchData(0xa, chip);
        DSP_DispatchData((unsigned char)((v >> 17) & 0x7f), chip);
        DSP_DispatchData((unsigned char)((v >> 9) & 0xff), chip);
        DSP_DispatchData((unsigned char)((v >> 1) & 0xff), chip);
        DSP_DispatchData((unsigned char)(((v << 7) & 0x80) + 0x15), chip);
    }
}
