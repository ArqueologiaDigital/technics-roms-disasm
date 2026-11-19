/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23m3.c (2026-11-19-3-sub-r23m-frame)
   sha256 41d6ffc8e47eaee247ee6f4d321fdc9d9fca3dabff46ae6f69ad15435b95dd54 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned long DSP_MixerGain_Curve[];
extern long __near DSP2_MixerGain_Curve[];
extern int DSP_DispatchCommand(int d, int chip);
extern int DSP_DispatchData(int d, int chip);
extern void DSP2_SPI_BusIdle(void);
extern void DSP_Bytecode_NotifyStateChange(void);
void DSP_MixerCoeff_Compute(unsigned int a, unsigned int b, unsigned int c)
{
    long w;
    float f;
    unsigned long v;
    register long *p;

    v = (DSP2_MixerGain_Curve[c] >> 15) * (((DSP2_MixerGain_Curve[a] >> 16) * (DSP_MixerGain_Curve[b] >> 15)) >> 16);
    p = &DSP2_MixerGain_Curve[a];
    f = *p;
    w = f;
    DSP_DispatchCommand(0x30, 1);
    DSP_DispatchData(0, 1);
    DSP_DispatchData(0xd0, 1);
    DSP_DispatchData(v >> 24, 1);
    DSP_DispatchData(v >> 16, 1);
    DSP2_SPI_BusIdle();
    DSP_Bytecode_NotifyStateChange();
    DSP_DispatchCommand(0x30, 1);
    DSP_DispatchData(0, 1);
    DSP_DispatchData(0xd3, 1);
    DSP_DispatchData((unsigned long)w >> 25, 1);
    DSP_DispatchData((unsigned long)w >> 17, 1);
    DSP2_SPI_BusIdle();
    DSP_Bytecode_NotifyStateChange();
}
