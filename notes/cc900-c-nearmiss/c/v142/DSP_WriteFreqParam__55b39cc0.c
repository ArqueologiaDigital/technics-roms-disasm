/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_7b.c (2026-11-16-79-sub-r7)
   sha256 55b39cc070036b9caa2848a386c36cf52910262a58cbf514c079d7e1af9f81a1 (name+funcs); compiled at -Xr */
extern int DSP_DispatchData(int d, int chip);
extern void DSP_WriteParamCmd30(int chip, unsigned int b, long v);
void DSP_WriteFreqParam(unsigned int a, long v, int chip, unsigned int base)
{
    switch (chip) {
    case 1:
            DSP_WriteParamCmd30(chip, a, v);
        break;
    default:
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
        break;
    }
}
