/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_4a.c (2026-11-16-62-sub-r4)
   sha256 a24cf77f8f049afccae4323475659f7526d8e2c4b8ca651c8900655a87adb798 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_413c9[];
extern unsigned char DSP_AlgoChannel_SelectorByte5[][6];
extern unsigned char DSP_ChanFreq_CurvePool[];
void DSP_ChanFreq_WritePacket2(unsigned char part)
{
    unsigned int r;
    unsigned char t;
    unsigned char sel;
    t = (*(unsigned char **)(ram_4136e + part * 0x11f))[93] & 0xf;
    switch (t) {
    case 6:
    case 7:
        sel = DSP_AlgoChannel_SelectorByte5[t][0];
        r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)sel * 0x66))[(*(unsigned char **)(ram_4136e + part * 0x11f))[95]];
        break;
    default:
        r = 0;
    }
    *(unsigned int *)(ram_413c9 + part * 0x11f) = r;
}
