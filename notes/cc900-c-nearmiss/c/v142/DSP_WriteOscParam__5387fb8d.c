/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_7a.c (2026-11-16-79-sub-r7)
   sha256 5387fb8dc1a4a10ac803200b808b9746db79da03261b93a1784389397bca675d (name+funcs); compiled at -Xr */
extern int DSP_DispatchData(int d, int chip);
extern void DSP_WriteParamCmd30(int chip, unsigned int b, long v);
void DSP_WriteOscParam(unsigned int a, long v, int chip, unsigned int base)
{
    switch (chip) {
    default:
            DSP_DispatchData(8, chip);
            DSP_DispatchData(1, chip);
            DSP_DispatchData((unsigned char)(((base + a) >> 4) & 0xf), chip);
            DSP_DispatchData((unsigned char)((((base + a) << 4) & 0xf0) + 8), chip);
            DSP_DispatchData(0x21, chip);
            DSP_DispatchData(0xa, chip);
            DSP_DispatchData((unsigned char)((v >> 17) & 0x7f), chip);
            DSP_DispatchData((unsigned char)((v >> 9) & 0xff), chip);
            DSP_DispatchData((unsigned char)((v >> 1) & 0xff), chip);
            DSP_DispatchData((unsigned char)(((v << 7) & 0x80) + 0x26), chip);
        break;
    case 1:
            DSP_WriteParamCmd30(chip, a, v);
        break;
    }
}
