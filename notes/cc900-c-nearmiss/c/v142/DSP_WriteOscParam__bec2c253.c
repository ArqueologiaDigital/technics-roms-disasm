/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_S_17c.c (2026-11-16-126-sub-r17)
   sha256 bec2c25332212d3f84070487797a054b721c978b18122ee7477faf31186b6cb0 (name+funcs); compiled at -Xr */
extern void DSP_WriteParamCmd30(int chip, unsigned int b, long v);
extern int DSP_DispatchData(int d, int chip);
int DSP_WriteOscParam(volatile unsigned int a, long v, int chip, int base)
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
